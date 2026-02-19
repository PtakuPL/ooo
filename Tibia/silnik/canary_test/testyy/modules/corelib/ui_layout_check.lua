--[[
  UI Layout Overflow Check — debug/regression tool
  
  Usage (in client console):
    dofile("modules/corelib/ui_layout_check")
    checkLayoutOverflow()           -- check all visible widgets, print problems
    checkLayoutOverflow(someWidget) -- check a specific subtree
    
  Detects child widgets that overflow their parent's padding rect.
  Useful for catching i18n text overflow and auto-fit-parent regression.
]]

function checkLayoutOverflow(widget, results, depth)
    depth = depth or 0
    results = results or {}
    
    if not widget then
        widget = rootWidget
    end
    
    if not widget or not widget:isVisible() then
        return results
    end
    
    local parent = widget:getParent()
    if parent and parent:isVisible() then
        local pr = parent:getPaddingRect()
        local cr = widget:getRect()
        local widgetId = widget:getId() or "?"
        local parentId = parent:getId() or "?"
        
        -- Width overflow check (2px tolerance for border/rounding)
        if cr:right() > pr:right() + 2 then
            table.insert(results, {
                widget = widgetId,
                parent = parentId,
                axis = "width",
                overflow = cr:right() - pr:right(),
                depth = depth
            })
        end
        
        -- Height overflow check
        if cr:bottom() > pr:bottom() + 2 then
            table.insert(results, {
                widget = widgetId,
                parent = parentId,
                axis = "height",
                overflow = cr:bottom() - pr:bottom(),
                depth = depth
            })
        end
    end
    
    -- Recurse into children
    local childCount = widget:getChildCount()
    for i = 1, childCount do
        local child = widget:getChildByIndex(i)
        if child then
            checkLayoutOverflow(child, results, depth + 1)
        end
    end
    
    -- If top-level call, print summary
    if depth == 0 then
        if #results == 0 then
            print("[LayoutCheck] No overflow detected — all widgets fit within parents.")
        else
            print(string.format("[LayoutCheck] Found %d overflow(s):", #results))
            for _, r in ipairs(results) do
                print(string.format("  [%s] widget '%s' overflows parent '%s' by +%dpx (%s)",
                    r.axis, r.widget, r.parent, r.overflow, r.axis))
            end
        end
    end
    
    return results
end

-- Quick check for options window specifically
function checkOptionsOverflow()
    local optionsWindow = rootWidget:recursiveGetChildById('optionsWindow')
    if not optionsWindow then
        print("[LayoutCheck] Options window not found (not loaded yet?)")
        return {}
    end
    return checkLayoutOverflow(optionsWindow)
end
