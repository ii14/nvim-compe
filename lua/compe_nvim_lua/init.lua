local Pattern = require'compe.pattern'

local Source = {}

function Source.new()
  local self = setmetatable({}, { __index = Source })
  self.regex = vim.regex('\\%(\\.\\|\\w\\)\\+$')
  return self
end

function Source.get_metadata(self)
  return {
    priority = 100;
    dup = 0;
    menu = '[Lua]';
    filetype = {'lua'}
  }
end

function Source.datermine(self, context)
  return {
    keyword_pattern_offset = Pattern:get_keyword_pattern_offset(context);
    trigger_character_offset = context.before_char == '.' and context.col or 0;
  }
end

function Source.complete(self, args)
  local s, e = self.regex:match_str(args.context.before_line)
  if not s then
    return args.abort()
  end

  local prefix = args.context.before_line
  prefix = string.sub(prefix, s + 1)
  prefix = string.gsub(prefix, '[^.]*$', '')

  args.callback({
    items = self:collect(vim.split(prefix, '.', true)),
  })
end

function Source.collect(self, paths)
  local target = _G
  local target_keys = vim.tbl_keys(_G)
  for i, path in ipairs(paths) do
    if vim.tbl_contains(target_keys, path) and type(target[path]) == 'table' then
      target = target[path]
      target_keys = vim.tbl_keys(target)
    elseif path ~= '' then
      return {}
    end
  end
  return target_keys
end

return Source.new()