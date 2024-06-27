using Pkg: Pkg

function Check_Dependencies()
	installed_packages = Pkg.project().dependencies
	required_packages  = ("JSON", "ArgParse", "OrderedCollections", "Cascadia", "Gumbo", "HTTP")
	prepare_to_install = String[]

	for package in required_packages
		haskey(installed_packages, package) || push!(prepare_to_install, package)
	end

	if !isempty(prepare_to_install)
		@info "Installing Prerequisites..."
		Pkg.add(prepare_to_install)
		@info "Prerequisites Installed ✔"
	end
end

# check dependencies to be installed
Check_Dependencies()
