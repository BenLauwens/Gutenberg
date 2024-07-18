#!julia

using Pkg
Pkg.activate(joinpath(@__DIR__, "..", "."))
using ArgParse
using Gutenberg

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input", "-i"
        help = "input"
        arg_type = String
        required = true
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    watch_and_tohtml(parsed_args["input"])
end

main()