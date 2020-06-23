
mutable struct SecretKey
  handle::Ptr{Cvoid}

  function SecretKey()
    handleref = Ref{Ptr{Cvoid}}(C_NULL)
    retval = ccall((:SecretKey_Create, libsealc), Clong,
                   (Ref{Ptr{Cvoid}},),
                   handleref)
    check_return_value(retval)
    return SecretKey(handleref[])
  end

  function SecretKey(handle::Ptr{Cvoid})
    x = new(handle)
    finalizer(x) do x
      # @async println("Finalizing $x at line $(@__LINE__).")
      ccall((:SecretKey_Destroy, libsealc), Clong,
            (Ptr{Cvoid},),
            x.handle)
    end
    return x
  end
end

