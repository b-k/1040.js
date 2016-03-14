js:
	cd forms; m4 -P pull_fns.m4 f1040.m4 | grep -v '>>>>' > ../fns
	cd forms; m4 -P pull_nodes.m4 f1040.m4 | grep -v '>>>>' > ../nodes
	cd forms; m4 -P pull_deps.m4 f1040.m4 | grep -v '\[ ""\]' | grep -v '_divider' > ../edges
	m4 -P another_demo.html.m4 > tax.html
