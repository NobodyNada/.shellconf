local M = {
    "lspsettings",
    name = "lspsettings",
    dev = {true},
    settings = {},
}

function M.extend(settings)
    M.settings = vim.tbl_deep_extend("force", M.settings, settings)
end

return M
