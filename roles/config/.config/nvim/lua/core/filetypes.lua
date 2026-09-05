local M = {}

function M.setup()
	vim.filetype.add({
		extension = {
			htmx = 'htmx',
			j2 = 'jinja',
			jinja = 'jinja',
			jinja2 = 'jinja',
			tf = 'terraform',
			tfvars = 'terraform-vars',
		},
		pattern = {
			['.*/ansible/.*%.ya?ml'] = 'yaml.ansible',
			['.*/playbooks?/.*%.ya?ml'] = 'yaml.ansible',
			['.*playbook.*%.ya?ml'] = 'yaml.ansible',
		},
	})
end

return M
