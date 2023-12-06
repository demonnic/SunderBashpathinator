function table.nmove(tbl, pos, newPos)
  local item = table.remove(tbl, pos)
  table.insert(tbl, newPos, item)
  return tbl
end

function table.raise(tbl, pos)
  if pos <= 1 then
    return tbl
  end
  table.nmove(tbl, pos, pos - 1)
  return tbl
end

function table.lower(tbl, pos)
  if pos >= #tbl then
    return tbl
  end
  table.nmove(tbl, pos, pos + 1)
  return tbl
end

function table.top(tbl, pos)
  if pos == 1 then
    return tbl
  end
  table.nmove(tbl, pos, 1)
  return tbl
end

function table.bottom(tbl, pos)
  if pos == #tbl then
    return tbl
  end
  table.nmove(tbl, pos, #tbl)
  return tbl
end