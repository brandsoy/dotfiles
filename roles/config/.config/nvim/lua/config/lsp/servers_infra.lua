local M = {}

function M.get()
	return {
		dockerls = {},
		terraformls = { filetypes = { 'terraform', 'terraform-vars' } },
		prismals = { filetypes = { 'prisma' } },
	}
end

return M
