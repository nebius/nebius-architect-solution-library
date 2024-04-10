[master]
${master}


[nodes]
${nodes}


[master:vars]
is_mysql=%{ if is_mysql }1%{ else }0%{ endif }
