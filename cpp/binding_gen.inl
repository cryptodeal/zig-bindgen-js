
void* fl_rand(void* shape_ptr, int64_t shape_len) {
  try {
    LOCK_GUARD

    auto shape = arrayArg<long long>(shape_ptr, shape_len, g_row_major, false);
    fl::Tensor t;
    t = fl::rand(fl::Shape(shape));
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_randn(void* shape_ptr, int64_t shape_len) {
  try {
    LOCK_GUARD

    auto shape = arrayArg<long long>(shape_ptr, shape_len, g_row_major, false);
    fl::Tensor t;
    t = fl::randn(fl::Shape(shape));
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_full(void* shape_ptr, int64_t shape_len, float val) {
  try {
    LOCK_GUARD

    auto shape = arrayArg<long long>(shape_ptr, shape_len, g_row_major, false);
    fl::Tensor t;
    t = fl::full(fl::Shape(shape), val);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_identity(int64_t dim) {
  try {
    LOCK_GUARD

    fl::Tensor t;
    t = fl::identity(dim);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_arange(float start, float end, float step) {
  try {
    LOCK_GUARD

    fl::Tensor t;
    t = fl::arange(start, end, step);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_iota(void* dims_ptr,
            int64_t dims_len,
            void* tileDims_ptr,
            int64_t tileDims_len) {
  try {
    LOCK_GUARD

    auto dims = arrayArg<long long>(dims_ptr, dims_len, g_row_major, false);
    auto tileDims =
        arrayArg<long long>(tileDims_ptr, tileDims_len, g_row_major, false);
    fl::Tensor t;
    t = fl::iota(fl::Shape(dims), fl::Shape(tileDims));
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_reshape(void* tensor, void* shape_ptr, int64_t shape_len) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto shape = arrayArg<long long>(shape_ptr, shape_len, g_row_major, false);
    fl::Tensor t;
    t = fl::reshape(*tensor_ptr, fl::Shape(shape));
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_transpose(void* tensor, void* axes_ptr, int64_t axes_len) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes = arrayArg<long long>(axes_ptr, axes_len, g_row_major,
                                    tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::transpose(*tensor_ptr, fl::Shape(axes));
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_tile(void* tensor, void* shape_ptr, int64_t shape_len) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto shape = arrayArg<long long>(shape_ptr, shape_len, g_row_major, false);
    fl::Tensor t;
    t = fl::tile(*tensor_ptr, fl::Shape(shape));
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_concatenate(void* tensors_ptr, int64_t tensors_len, int32_t axis) {
  try {
    LOCK_GUARD

    auto tensors = ptrArrayArg<fl::Tensor>(tensors_ptr, tensors_len);
    auto used_axis = axisArg(axis, g_row_major, (&tensors[0])->ndim());
    fl::Tensor t;
    t = fl::concatenate(tensors, used_axis);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_nonzero(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::nonzero(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_negative(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::negative(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_logicalNot(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::logicalNot(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_exp(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::exp(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_log(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::log(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_log1p(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::log1p(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sin(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::sin(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_cos(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::cos(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sqrt(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::sqrt(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_tanh(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::tanh(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_floor(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::floor(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_ceil(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::ceil(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_rint(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::rint(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_absolute(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::absolute(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sigmoid(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::sigmoid(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_erf(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::erf(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_flip(void* tensor, uint32_t dim) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::flip(*tensor_ptr, dim);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_clip(void* tensor, void* low, void* high) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* low_ptr = reinterpret_cast<fl::Tensor*>(low);
    auto* high_ptr = reinterpret_cast<fl::Tensor*>(high);
    fl::Tensor t;
    t = fl::clip(*tensor_ptr, *low_ptr, *high_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_roll(void* tensor, int shift, int32_t axis) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto used_axis = axisArg(axis, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::roll(*tensor_ptr, shift, used_axis);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_isnan(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::isnan(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_isinf(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::isinf(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sign(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::sign(*tensor_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_tril(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    if (g_row_major) {
      t = fl::triu(*tensor_ptr);
    } else {
      t = fl::tril(*tensor_ptr);
    }
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_triu(void* tensor) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    if (g_row_major) {
      t = fl::tril(*tensor_ptr);
    } else {
      t = fl::triu(*tensor_ptr);
    }
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_where(void* cond, void* x, void* y) {
  try {
    LOCK_GUARD

    auto* cond_ptr = reinterpret_cast<fl::Tensor*>(cond);
    auto* x_ptr = reinterpret_cast<fl::Tensor*>(x);
    auto* y_ptr = reinterpret_cast<fl::Tensor*>(y);
    fl::Tensor t;
    t = fl::where(cond_ptr->astype(fl::dtype::b8), *x_ptr, *y_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sort(void* tensor, uint32_t dim) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    fl::Tensor t;
    t = fl::sort(*tensor_ptr, dim);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_add(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::add(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sub(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::sub(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_mul(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::mul(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_div(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::div(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_eq(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::eq(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_neq(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::neq(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_lessThan(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::lessThan(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_lessThanEqual(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::lessThanEqual(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_greaterThan(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::greaterThan(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_greaterThanEqual(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::greaterThanEqual(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_logicalOr(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::logicalOr(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_logicalAnd(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::logicalAnd(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_mod(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::mod(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_bitwiseAnd(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::bitwiseAnd(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_bitwiseOr(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::bitwiseOr(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_bitwiseXor(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::bitwiseXor(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_lShift(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::lShift(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_rShift(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::rShift(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_minimum(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::minimum(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_maximum(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::maximum(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_power(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    t = fl::power(*tensor_ptr, *other_ptr);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_matmul(void* tensor, void* other) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* other_ptr = reinterpret_cast<fl::Tensor*>(other);
    fl::Tensor t;
    if (g_row_major) {
      t = fl::matmul(*other_ptr, *tensor_ptr);
    } else {
      t = fl::matmul(*tensor_ptr, *other_ptr);
    }
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_conv2d(void* tensor,
              void* weights,
              int32_t sx,
              int32_t sy,
              int32_t px,
              int32_t py,
              int32_t dx,
              int32_t dy,
              int32_t groups) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto* weights_ptr = reinterpret_cast<fl::Tensor*>(weights);
    fl::Tensor t;
    t = fl::conv2d(*tensor_ptr, *weights_ptr, sx, sy, px, py, dx, dy, groups);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_amin(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::amin(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_amax(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::amax(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_argmin(void* tensor, int32_t axis, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto used_axis = axisArg(axis, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::argmin(*tensor_ptr, used_axis, keep_dims);

    auto axes_set = std::unordered_set<int>{static_cast<int>(used_axis)};
    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_argmax(void* tensor, int32_t axis, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto used_axis = axisArg(axis, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::argmax(*tensor_ptr, used_axis, keep_dims);

    auto axes_set = std::unordered_set<int>{static_cast<int>(used_axis)};
    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_sum(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::sum(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_cumsum(void* tensor, int32_t axis) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto used_axis = axisArg(axis, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::cumsum(*tensor_ptr, used_axis);
    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_mean(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::mean(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_median(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::median(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_var(void* tensor,
           void* axes_ptr,
           int64_t axes_len,
           bool bias,
           bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::var(*tensor_ptr, axes, bias, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_std(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::std(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_norm(void* tensor,
            void* axes_ptr,
            int64_t axes_len,
            double p,
            bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::norm(*tensor_ptr, axes, p, keep_dims);

    if (p == std::numeric_limits<double>::infinity()) {
      t = fl::abs(*tensor_ptr);
      t = fl::amax(t, axes, keep_dims);
    }

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_countNonzero(void* tensor,
                    void* axes_ptr,
                    int64_t axes_len,
                    bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::countNonzero(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_any(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::any(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}

void* fl_all(void* tensor, void* axes_ptr, int64_t axes_len, bool keep_dims) {
  try {
    LOCK_GUARD

    auto* tensor_ptr = reinterpret_cast<fl::Tensor*>(tensor);
    auto axes =
        arrayArg<int>(axes_ptr, axes_len, g_row_major, tensor_ptr->ndim());
    fl::Tensor t;
    t = fl::all(*tensor_ptr, axes, keep_dims);

    auto axes_set = std::unordered_set<int>(axes.begin(), axes.end());

    auto base_shape = tensor_ptr->shape().get();
    std::vector<fl::Dim> new_shape;
    for (auto idx = 0; idx < base_shape.size(); ++idx) {
      if (axes_set.count(idx) || (axes_set.size() == 0)) {
        if (keep_dims) {
          new_shape.emplace_back(1);
        }
        continue;
      }
      new_shape.emplace_back(base_shape[idx]);
    }
    const auto& shape = fl::Shape(new_shape);
    t = fl::reshape(t, shape);

    g_bytes_used += t.bytes();
    return new fl::Tensor(t);
  } catch (std::exception const& e) {
    HANDLE_EXCEPTION(e.what());
  } catch (...) {
    HANDLE_EXCEPTION("[unknown]");
  }
}
