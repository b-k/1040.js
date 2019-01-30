Forms = f1040.m4 schedule_a.m4 schedule_e.m4 f8582.m4
tax.html: forms/f* 1040.html.m4
	cd forms; m4 -P pull_fns.m4 $(Forms) | grep -v '>>>>' > ../fns
	cd forms; m4 -P pull_nodes.m4 $(Forms) | grep -v '>>>>' > ../nodes
	cd forms; m4 -P pull_deps.m4 $(Forms)  | grep -v '\[ ""\]' | grep -v '_divider' > ../edges
	m4 -P 1040.html.m4 > tax.html

clean:
	rm -f fns nodes edges tax.html

pages: tax.html
	git co gh-pages
	cp tax.html index.html
