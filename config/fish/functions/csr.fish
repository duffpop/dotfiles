function csr
  if test (count $argv) -eq 0
    cursor .
  else
    cursor $argv
  end
end
