
module SchemeType
@enum SchemeTypeEnum::UInt8 none=0 bfv=1 ckks=2
end

mutable struct EncryptionParameters
  handle::Ptr{Cvoid}

  function EncryptionParameters(scheme::SchemeType.SchemeTypeEnum)
    handleref = Ref{Ptr{Cvoid}}(C_NULL)
    ccall((:EncParams_Create1, libsealc), Clong,
          (UInt8, Ref{Ptr{Cvoid}}),
          scheme, handleref)
    x = new(handleref[])
    finalizer(x) do x
      # @async println("Finalizing $x at line $(@__LINE__).")
      ccall((:EncParams_Destroy, libsealc), Clong,
            (Ptr{Cvoid},),
            x.handle)
    end
    return x
  end
end

function get_poly_modulus_degree(enc_param::EncryptionParameters)
  degree = Ref{UInt64}(0)
  ccall((:EncParams_GetPolyModulusDegree, libsealc), Clong,
        (Ptr{Cvoid}, Ref{UInt64}),
        enc_param.handle, degree)
  return Int(degree[])
end

function set_poly_modulus_degree!(enc_param::EncryptionParameters, degree)
  ccall((:EncParams_SetPolyModulusDegree, libsealc), Clong,
        (Ptr{Cvoid}, UInt64),
        enc_param.handle, degree)
  return enc_param
end

function set_coeff_modulus!(enc_param::EncryptionParameters, coeff_modulus)
  coeff_modulus_ptrs = Ptr{Cvoid}[cm.handle for cm in coeff_modulus]
  ccall((:EncParams_SetCoeffModulus, libsealc), Clong,
        (Ptr{Cvoid}, UInt64, Ref{Ptr{Cvoid}}),
        enc_param.handle, length(coeff_modulus), coeff_modulus_ptrs)
  return enc_param
end

function coeff_modulus(enc_param::EncryptionParameters)
  len = Ref{UInt64}(0)

  # First call to obtain length
  ccall((:EncParams_GetCoeffModulus, libsealc), Clong,
        (Ptr{Cvoid}, Ref{UInt64}, Ref{Ptr{Cvoid}}),
        enc_param.handle, len, Ref{Ptr{Cvoid}}(C_NULL))

  # Second call to obtain modulus
  modulusptrs = Vector{Ptr{Cvoid}}(undef, len[])
  ccall((:EncParams_GetCoeffModulus, libsealc), Clong,
        (Ptr{Cvoid}, Ref{UInt64}, Ref{Ptr{Cvoid}}),
        enc_param.handle, len, modulusptrs)

  modulus = Modulus[Modulus(ptr) for ptr in modulusptrs]
  return modulus
end

