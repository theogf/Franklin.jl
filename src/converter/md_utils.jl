"""
    md2html(ss, stripp)

Convenience function to call the base markdown to html converter on "simple" strings (i.e. strings
that don't need to be further considered and don't contain anything else than markdown tokens).
The boolean `stripp` indicates whether to remove the inserted `<p>` and `</p>` by the base markdown
processor, this is relevant for things that are parsed within latex commands etc.
"""
function md2html(ss::AbstractString,
                 stripp = false)

    isempty(ss) && return ss
    # Use the base Markdown -> Html converter
    partial = Markdown.html(Markdown.parse(ss))

    # In some cases, base converter adds <p>...</p>\n which we might not want
    stripp && begin
        startswith(partial, "<p>")  && (partial = chop(partial, head=3))
        endswith(partial, "</p>") && (partial = chop(partial, tail=4))
        endswith(partial, "</p>\n") && (partial = chop(partial, tail=5))
    end

    return partial
end


"""
    from_ifsmaller(v, idx, len)

Convenience function to check if `idx` is smaller than the length of `v`, if it is, then return the starting point of `v[idx]` (via `from`), otherwise return `BIG_INT`.
"""
from_ifsmaller(v::Vector, idx, len) = (idx > len) ? BIG_INT : from(v[idx])


"""
    deactivate_divs

Since divs are recursively processed, once they've been found, everything inside them needs to be
deactivated and left for further re-processing to avoid double inclusion.
"""
function deactivate_divs(blocks::Vector{OCBlock})

    active_blocks = ones(Bool, length(blocks))
    for (i, β) ∈ enumerate(blocks)
        fromβ, toβ = from(β), to(β)
        active_blocks[i] || continue
        if β.name == :DIV
            innerblocks = findall(b -> (fromβ < from(b) < toβ), blocks)
            active_blocks[innerblocks] .= false
        end
    end
    return blocks[active_blocks]
end