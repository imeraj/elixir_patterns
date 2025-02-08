# hash
:crypto.hash(:blake2s, "This is some data") |> Base.encode16()

:crypto.hash(:blake2s, "This is some other data") |> Base.encode16()

:crypto.hash(:sha256, "This is some data") |> Base.encode16()

# HMAC
generate_hmac = fn secret, payload ->
  :hmac
  |> :crypto.mac(:sha256, secret, payload)
  |> Base.encode64()
end

validate_hmac = fn secret, payload, expected_hash ->
  :hmac
  |> :crypto.mac(:sha256, secret, payload)
  |> Base.encode64()
  |> Kernel.==(expected_hash)
end

payload = :erlang.term_to_binary(%{some: "Data", i: "Need"})

secret_key = "this_is_a_secret_and_secure_key"

correct_hmac_hash = generate_hmac.(secret_key, payload)

validate_hmac.("INVALID_KEY", payload, correct_hmac_hash)

validate_hmac.(secret_key, payload, correct_hmac_hash)

# symmetric encryption
encrypt = fn message, key ->
  opts = [encrypt: true, padding: :zero]
  :crypto.crypto_one_time(:aes_256_ecb, key, message, opts)
end

decrypt = fn payload, key ->
  opts = [encrypt: false]

  :crypto.crypto_one_time(:aes_256_ecb, key, payload, opts)
  |> String.trim_trailing(<<0>>)
end

message = "This is a very very important message. Keep it secret...keep safe"
secret_key = :crypto.strong_rand_bytes(32)

encrypted_message = encrypt.(message, secret_key)

try do
  decrypt.(encrypted_message, "INVALID_KEY")
rescue
  error -> error
end

decrypted_message = decrypt.(encrypted_message, :crypto.strong_rand_bytes(32))

decrypted_message = decrypt.(encrypted_message, secret_key)
