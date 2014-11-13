Bash Template Engine
====================

simple templating engine for bash

Very Simple Templating Engine


#### Usage

```bash

local grove_id="001"
local name="ferron"


./tmpl.sh "Grove id {{grove_id}} and name {{name}}"

# transposes to :
# ./tmpl.sh "Grove id grove_id and name ferron"

```
