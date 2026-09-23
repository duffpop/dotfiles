function c
  if test (count $argv) -eq 0
    code-insiders .
  else
    code-insiders $argv
  end
end
