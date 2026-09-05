local M = {}

function M.get()
	return {
		ansiblels = {
			root_markers = { 'ansible.cfg', '.ansible-lint', '.git' },
		},
		dockerls = {},
		tflint = {},
		terraformls = { filetypes = { 'terraform', 'terraform-vars' } },
		prismals = { filetypes = { 'prisma' } },
	}
end

return M
