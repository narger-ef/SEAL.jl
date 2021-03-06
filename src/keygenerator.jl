
"""
    KeyGenerator

Can be used to generate a pair of matching secret and public keys. In addition, the `KeyGenerator`
provides functions to obtain relinearization keys (required after multiplication) and Galois keys
(needed for rotation).

See also: [`SecretKey`](@ref), [`PublicKey`](@ref), [`RelinKeys`](@ref)
"""
mutable struct KeyGenerator <: SEALObject
  handle::Ptr{Cvoid}

  function KeyGenerator(context::SEALContext)
    handleref = Ref{Ptr{Cvoid}}(C_NULL)
    retval = ccall((:KeyGenerator_Create1, libsealc), Clong,
                   (Ptr{Cvoid}, Ref{Ptr{Cvoid}}),
                   context, handleref)
    @check_return_value retval
    return KeyGenerator(handleref[])
  end

  function KeyGenerator(handle::Ptr{Cvoid})
    x = new(handle)
    finalizer(x) do x
      # @async println("Finalizing $x at line $(@__LINE__).")
      ccall((:KeyGenerator_Destroy, libsealc), Clong, (Ptr{Cvoid},), x)
    end
    return x
  end
end

function public_key(keygen::KeyGenerator)
  keyptr = Ref{Ptr{Cvoid}}(C_NULL)
  retval = ccall((:KeyGenerator_PublicKey, libsealc), Clong,
                 (Ptr{Cvoid}, Ref{Ptr{Cvoid}}),
                 keygen, keyptr)
  @check_return_value retval
  return PublicKey(keyptr[])
end

function secret_key(keygen::KeyGenerator)
  keyptr = Ref{Ptr{Cvoid}}(C_NULL)
  retval = ccall((:KeyGenerator_SecretKey, libsealc), Clong,
                 (Ptr{Cvoid}, Ref{Ptr{Cvoid}}),
                 keygen, keyptr)
  @check_return_value retval
  return SecretKey(keyptr[])
end

function relin_keys_local(keygen::KeyGenerator)
  keyptr = Ref{Ptr{Cvoid}}(C_NULL)
  retval = ccall((:KeyGenerator_RelinKeys, libsealc), Clong,
                 (Ptr{Cvoid}, UInt8, Ref{Ptr{Cvoid}}),
                 keygen, false, keyptr)
  @check_return_value retval
  return RelinKeys(keyptr[])
end

function relin_keys(keygen::KeyGenerator)
  keyptr = Ref{Ptr{Cvoid}}(C_NULL)
  retval = ccall((:KeyGenerator_RelinKeys, libsealc), Clong,
                 (Ptr{Cvoid}, UInt8, Ref{Ptr{Cvoid}}),
                 keygen, true, keyptr)
  @check_return_value retval
  return RelinKeys(keyptr[])
end

function galois_keys_local(keygen::KeyGenerator)
  keyptr = Ref{Ptr{Cvoid}}(C_NULL)
  retval = ccall((:KeyGenerator_GaloisKeysAll, libsealc), Clong,
                 (Ptr{Cvoid}, UInt8, Ref{Ptr{Cvoid}}),
                 keygen, false, keyptr)
  @check_return_value retval
  return GaloisKeys(keyptr[])
end
