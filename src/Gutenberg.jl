module Gutenberg

using Dates
using TOML
using FileWatching
using IOCapture
using CommonMark

export topdf, tohtml, watch_and_tohtml

const TIMEOUT = 1000

const TEMPLATE = """<!DOCTYPE html>
<html lang=”en”>
<head>
<meta charset="utf-8">
<title>TITLE</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/default.min.css" />
<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/highlight.min.js"></script>
<script src="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/languages/julia.min.js"></script>
<link rel="stylesheet" href="rma.css" />
<script src="../assets/temml.min.js"></script>
PAGED
</head>
<body data-type="BODY-TYPE">
BODY
</body>
</html>
"""

const PAGED = """<script src="https://unpkg.com/pagedjs/dist/paged.polyfill.js"></script>
<script>
class handlers extends Paged.Handler {
    constructor(chunker, polisher, caller) {
        super(chunker, polisher, caller);
    }

    beforeParsed(content) {
        for (let el of content.querySelectorAll('div[data-type="equation"]')) {
            const math = document.createElement('span');
            temml.render(el.innerHTML.slice(3, -3).replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&"), math, { displayMode: true, output: 'mathml', throwOnError: false});
            el.replaceChildren(math);
            el.removeAttribute('class');
        }
        for (let el of content.querySelectorAll('foreignObject')) {
            const math = document.createElement('span');
            temml.render(el.innerHTML.slice(3, -3).replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&"), math, { displayMode: false, output: 'mathml', throwOnError: false});
            el.replaceChildren(math);
        }
        for (let el of content.querySelectorAll('span[data-type="tex"]')) {
            temml.render(el.innerHTML.slice(2, -2).replaceAll("&lt;", "<").replaceAll("&gt;", ">").replaceAll("&amp;", "&"), el, { displayMode: false, output: 'mathml', throwOnError: false});
            el.removeAttribute('data-type');
            el.removeAttribute('class');
        }
        for (let el of content.querySelectorAll('pre code')) {
            hljs.highlightElement(el);
        }
        let nav = content.querySelector('nav[data-type="toc"]');
        if (!nav) {
            console.warn('no nav found');
        } else {
            let tocElementNbr = 0;
            const selectors = ['section[data-type="chapter"]>h1', 'section[data-type="chapter"] section[data-type="sect1"]>h1'];
            for (let i = 0; i < selectors.length; i++) {
                for (let el of content.querySelectorAll(selectors[i])) {
                    el.classList.add('toc-element');
                    el.setAttribute('data-toc-level', i + 1);
                    if (el.id == '') {
                        el.id = 'toc-element-' + tocElementNbr++;
                    }
                }
            }
            let level = 0;
            let toc = document.createElement('div');
            toc.appendChild(document.createElement('div'));
            let entry = toc;
            for (let el of content.querySelectorAll('.toc-element')) {
                if (el.dataset.tocLevel > level) {
                    level++;
                    entry = document.createElement('ol');
                    toc.lastChild.appendChild(entry);
                    toc = entry;
                } else if (el.dataset.tocLevel < level) {
                    toc = toc.parentElement.parentElement;
                    level--;
                }
                entry = document.createElement('li');
                entry.innerHTML = '<a href= "#' + el.id + '" >' + el.innerHTML + '</a>';
                toc.appendChild(entry);
            }
            while (level > 1) {
                toc = toc.parentElement.parentElement;
                level--;
            }
            nav.appendChild(toc);
        }
    }

    afterRendered(pages) {
        const element = document.getElementById('tag');
        if (element) {
            element.scrollIntoView();
        }
    }
}

Paged.registerHandlers(handlers);
</script>
"""

function Base.show(io::IO, ::MIME"text/html", val::Any)
    write(io, """<div data-type="programresult">\n""")
    for line in split(string(val), "\n")
        write(io, line, "\n")
    end
    write(io, "</div>\n")
end

const PARSER = Parser()

enable!(PARSER, FootnoteRule())
enable!(PARSER, TypographyRule())
enable!(PARSER, AdmonitionRule())
enable!(PARSER, MathRule())
enable!(PARSER, TableRule())
enable!(PARSER, RawContentRule())
enable!(PARSER, AttributeRule())
enable!(PARSER, CitationRule())
enable!(PARSER, FrontMatterRule(toml=TOML.parse))

function ismarkdown(file::String)
    _, ext = splitext(file)
    return isfile(file) && ext === ".md"
end

function _html(buf::Vector{String}, type::Any, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    println(string(entering) * " " * string(type) * string(" ") * string(str) * " " * string(attributes))
    push!(buf, "ERRORERRORERROR")
    return level
end

function _html(_::Vector{String}, _::CommonMark.FrontMatter, _::Bool, _::String, _::Dict{String,Any}, level::Int64)
    return level
end

function _html(buf::Vector{String}, _::CommonMark.HtmlBlock, entering::Bool, str::String, _::Dict{String,Any}, level::Int64)
    if entering
        for line in split(str, "\n")
            push!(buf, strip(line))
        end
    end
    return level
end

function _html(_::Vector{String}, _::CommonMark.Attributes, _::Bool, _::String, _::Dict{String,Any}, level::Int64)
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Document, entering::Bool, _::String, _::Dict{String,Any}, level::Int64)
    if !entering
        for _ in level:-1:1
            push!(buf, "</section>")
        end
        level = 0
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Paragraph, entering::Bool, _::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        if haskey(attributes, "class")
            push!(buf, """<p class="$(attributes["class"]...)">""")
        else
            push!(buf, """<p>""")
        end
    else
        buf[end] *= "</p>"
    end
    return level
end

function _html(buf::Vector{String}, type::CommonMark.Heading, entering::Bool, _::String, attributes::Dict{String,Any}, level::Int64)
    tag = if type.level === 1
        "h1"
    else
        "h$(type.level-1)"
    end
    if entering
        if type.level === level
            level -= 1
            push!(buf, "</section>")
        end
        cl = if haskey(attributes, "class")
            """ class="$(attributes["class"]...)" """
        else
            ""
        end
        if type.level === 1
            push!(buf, """<section data-type="$(attributes["data-type"])"$cl>""")
        else
            push!(buf, """<section data-type="sect$(type.level-1)"$cl>""")
        end
        level += 1
        if haskey(attributes, "id")
            push!(buf, """<$tag id=$(attributes["id"])>""")
        else
            push!(buf, """<$tag>""")
        end
    else
        buf[end] *= "</$tag>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.DisplayMath, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        if haskey(attributes, "id")
            push!(buf, """<div class="math-tex" data-type="equation" id="$(attributes["id"])">""")
        else
            push!(buf, """<div class="math-tex" data-type="equation">""")
        end
        push!(buf, "\\[")
        for line in split(str, "\n")
            push!(buf, line)
        end
        push!(buf, "\\]")
        push!(buf, "</div>")
    end
    return level
end

function _html(buf::Vector{String}, type::CommonMark.Admonition, entering::Bool, _::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<div data-type="$(type.category)">""")
        if lowercase(type.category) !== lowercase(type.title)
            if haskey(attributes, "id")
                push!(buf, """<h1 id="$(attributes["id"])">&nbsp;(""" * type.title * ")</h1>")
            else
                push!(buf, """<h1>&nbsp;(""" * type.title * ")</h1>")
            end
        else
            if haskey(attributes, "id")
                push!(buf, """<h1 id="$(attributes["id"])"></h1>""")
            else
                push!(buf, """<h1></h1>""")
            end
        end
    else
        push!(buf, "</div>")
    end
    return level
end

function _html(buf::Vector{String}, type::CommonMark.List, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    tag = if type.list_data.type == :ordered
        "ol"
    else
        "ul"
    end
    if entering
        push!(buf, """<$tag>""")
    else
        push!(buf, "</$tag>")
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Table, entering::Bool, _::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<table>""")
    else
        push!(buf, "</table>")
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.TableHeader, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<thead>""")
        level += 1
    else
        level -= 1
        push!(buf, "</thead>")
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.TableBody, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<tbody>""")
    else
        push!(buf, "</tbody>")
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.TableRow, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<tr>""")
    else
        push!(buf, "</tr>")
    end
    return level
end

function _html(buf::Vector{String}, type::CommonMark.TableCell, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<td style="text-align:$(type.align)">""")
    else
        buf[end] *= "</td>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Item, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        push!(buf, """<li>""")
    else
        push!(buf, "</li>")
    end
    return level
end

const MODULES = Dict{String,Module}()

function _html(buf::Vector{String}, type::CommonMark.CodeBlock, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        language = type.info
        if get(attributes, "display", "true") === "true"
            push!(buf, """<pre data-type="programlisting" data-code-language="$language">""")
            push!(buf, """<code class="language-$language">""")
            buf[end] *= chop(str)
            buf[end] *= "</code>"
            push!(buf, "</pre>")
        end
        if haskey(attributes, "cell")
            sandbox = get!(MODULES, String(attributes["cell"]), Module())
            captured = IOCapture.capture(rethrow=InterruptException) do
                include_string(sandbox, str)
            end
            if get(attributes, "output", "true") === "true" && captured.output !== ""
                push!(buf, """<pre data-type="programoutput">""")
                push!(buf, """<code>""")
                buf[end] *= chop(captured.output)
                buf[end] *= "</code>"
                push!(buf, "</pre>")
            end
            if get(attributes, "result", "true") === "true" && captured.value !== nothing
                valio = IOBuffer()
                invokelatest(show, valio, "text/html", captured.value)
                for line in split(chop(String(take!(valio))), "\n")
                    push!(buf, line)
                end
            end
        end
    end
    return level
end


function _html(buf::Vector{String}, _::CommonMark.Strong, entering::Bool, _::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        buf[end] *= "<b>"
    else
        buf[end] *= "</b>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Emph, entering::Bool, _::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        buf[end] *= "<i>"
    else
        buf[end] *= "</i>"
    end
    return level
end

function _html(buf::Vector{String}, link::CommonMark.Link, entering::Bool, _::String, _::Dict{String,Any}, level::Int64)
    if entering
        buf[end] *= """<a href="$(link.destination)">"""
    else
        buf[end] *= "</a>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Code, entering::Bool, str::String, attributes::Dict{String,Any}, level::Int64)
    if entering
        buf[end] *= "<code>" * str * "</code>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Math, entering::Bool, str::String, _::Dict{String,Any}, level::Int64)
    if entering
        buf[end] *= """<span class="math-tex" data-type="tex">\\(""" * str * "\\)</span>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.HtmlInline, entering::Bool, str::String, _::Dict{String,Any}, level::Int64)
    buf[end] *= str
    return level
end

function _html(buf::Vector{String}, _::CommonMark.SoftBreak, entering::Bool, _::String, _::Dict{String,Any}, level::Int64)
    if entering
        buf[end] *= "<br/>"
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Text, entering::Bool, str::String, _::Dict{String,Any}, level::Int)
    if entering
        buf[end] *= str
    end
    return level
end

function _html(buf::Vector{String}, _::CommonMark.Citation, entering::Bool, str::String, _::Dict{String,Any}, level::Int)
    if entering
        buf[end] *= str
    end
    return level
end

function _tohtml(file::String)
    ast = open(PARSER, file)
    buf = String[]
    level = 0
    for (node, entering) in ast
        level = _html(buf, node.t, entering, node.literal, node.meta, level)
    end
    return buf
end

function tohtml(file::String)
    if !ismarkdown(file)
        error(file, " is not a md file!")
    end
    path, _ = splitdir(file)
    ast = open(PARSER, file)
    meta = frontmatter(ast)
    body = ""
    get!(meta, "files", String[])
    pushfirst!(meta["files"], file)
    for file in meta["files"]
        println(file)
        body *= join(_tohtml(joinpath(path, file)), "\n") * "\n"
    end
    html = replace(TEMPLATE, "TITLE" => meta["title"], "PAGED" => PAGED, "BODY-TYPE" => "book", "BODY" => body)
    open(joinpath(path, meta["output"]), "w") do out
        write(out, html)
    end
end

function watch_and_tohtml(file::String)
    if !ismarkdown(file)
        error(file, " is not a md file!")
    end
    path, _ = splitdir(file)
    name, _ = splitext(file)
    prev = String[]
    while true
        println("Recompile at ", Dates.now())
        body = ""
        next = _tohtml(file)
        for (i, str) in enumerate(next)
            if i > length(prev) || str !== prev[i]
                body *= join(next[1:i-1], "\n")
                body *= (i === 1 ? "" : "\n") * """<div id="tag"></div>\n"""
                body *= join(next[i:end], "\n")
                break
            end
        end
        if body === ""
            body = join(next, "\n") * """<div id="tag"></div>\n"""
        end
        html = replace(TEMPLATE, "TITLE" => name, "PAGED" => "", "BODY-TYPE" => "article", "BODY" => body)
        open(joinpath(path, name * ".html"), "w") do out
            write(out, html)
        end
        state = watch_file(file, TIMEOUT)
        if !state.changed
            break
        end
        prev = next
    end
end

function topdf(file::String)

end

end
