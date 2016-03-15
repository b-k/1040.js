Forms = f1040.m4 schedule_a.m4 schedule_e.m4 f8582.m4
js:
	cd forms; m4 -P pull_fns.m4 $(Forms) | grep -v '>>>>' > ../fns
	cd forms; m4 -P pull_nodes.m4 $(Forms) | grep -v '>>>>' > ../nodes
	cd forms; m4 -P pull_deps.m4 $(Forms)  | grep -v '\[ ""\]' | grep -v '_divider' > ../edges
	m4 -P 1040.html.m4 > tax.html
