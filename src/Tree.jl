module Tree

export tree

if VERSION >= v"0.7.0-"
    using Dates
end

function colorprint(s, col)
    if VERSION >= v"0.7.0-"
        printstyled(s, color=col)
    else
        print_with_color(col, s)
    end
end

"""
    tree(path;
        maxdepth=6,
        linecolor=:light_black,
        dircolor=:yellow,
        ages=false)

Show the files in `path` in a basic tree, up to a depth of `maxdepth`.

The default value for maxdepth is 6 (which is way too big if you're high enough up in your
directory hierarchy). But the trouble with this option is that it doesn't show directories if
they're in the same directory as the lowest level files... (I think there are some
off-by-at-least one errors to track down.)

Also the scan takes place to deeper levels anyway, it just doesn't show them.

`linecolor` and `dircolor` are the colors for the connecting lines and directories.
The following work on my terminal:

```
:bold, :black, :blue, :cyan, :green, :light_black, :light_blue, :light_cyan, :light_green,
:light_magenta, :light_red, :light_yellow, :magenta, :red, :white, or :yellow
```

"""
function tree(path=".";
    maxdepth=6,
    linecolor=:light_black,
    dircolor=:yellow,
    ages=false)

    CORNER     = string(Char(0x2514)) # '└'
    HORIZONTAL = string(Char(0x2500)) # '─'

    # quit if not a directory
    !isdir(path) && error("Supply a directory")

    rootdepth = length(filter(!isempty, split(abspath(path), "/"))) - 1

    println("files in $(abspath(path)) | showing $maxdepth levels")

    for (root, dirs, files) in walkdir(abspath(path))

        depth = length(filter(!isempty, split(root, "/"))) - rootdepth

        d, f = splitdir(root)

        if depth > maxdepth
            continue
        else
            # print this directory:

            # leading spaces
            print(join(fill(" " ^ 4,  max(0, depth - 1))))

            # angle piece
            colorprint(string("$CORNER", join(fill("$HORIZONTAL" ^ 3, 1))), linecolor)

            # directory name
            colorprint(f * "\n", dircolor)

            # and its contents
            for f in files
                print(join(fill(" " ^ 4,  depth)))
                colorprint(string("$CORNER", join(fill("$HORIZONTAL" ^ 3, 1))), linecolor)
                print(f)
                if ages
                    status = stat(joinpath(path, root, f))
                    fileage = Dates.now() - Dates.unix2datetime(status.mtime)
                    daysold = round(convert(Float64, fileage.value/(1000 * 60 * 60 * 24)), 2)
                    print("\t($(daysold) days old) ")
                end
                println()
            end
        end
    end
end

end # module
