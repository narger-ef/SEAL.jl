
mutable struct Decryptor
  handle::Ptr{Cvoid}

  function Decryptor(context::SEALContext, secret_key::SecretKey)
    handleref = Ref{Ptr{Cvoid}}(C_NULL)
    retval = ccall((:Decryptor_Create, libsealc), Clong,
                   (Ptr{Cvoid}, Ptr{Cvoid}, Ref{Ptr{Cvoid}}),
                   context.handle, secret_key.handle, handleref)
    check_return_value(retval)
    return Decryptor(handleref[])
  end

  function Decryptor(handle::Ptr{Cvoid})
    x = new(handle)
    finalizer(x) do x
      # @async println("Finalizing $x at line $(@__LINE__).")
      ccall((:Decryptor_Destroy, libsealc), Clong,
            (Ptr{Cvoid},),
            x.handle)
    end
    return x
  end
end
