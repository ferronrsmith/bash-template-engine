Bash Template Engine
====================

simple templating engine for bash

Very Simple Templating Engine


#### Usage

```bash

# USER is a global variable that will be transposed to your current user name
./tmpl.sh "Hello {{USER}}, Your Grove id is {{grove_id}}"

# transposes to :
# ./tmpl.sh "Hello ferron, Your Grove id is 001"

```
