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
        "--output", "-o"
        help = "output"
        arg_type = String
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg, val) in parsed_args
        println("  $arg  =>  $val")
    end
end

main()