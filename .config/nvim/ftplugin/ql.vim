command -nargs=* CodeQLDB :lua require("codeql").set_db(<q-args>)
noremap r :lua require("codeql").run_query()<cr>
