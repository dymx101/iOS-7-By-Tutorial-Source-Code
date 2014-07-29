#generate the Black Friday pass
"$PROJECT_DIR/passdata" -i "$PROJECT_DIR/passes/bf3monthspass.plist" -p "$PROJECT_DIR/passes/bf3monthspass/pass.json"
"$PROJECT_DIR/signpass" -p "$PROJECT_DIR/passes/bf3monthspass" -o "$PROJECT_DIR/passes/bf3monthspass.pkpass"
