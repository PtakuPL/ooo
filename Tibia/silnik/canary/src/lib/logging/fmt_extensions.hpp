#include "pch.hpp"
// src/lib/logging/fmt_extensions.hpp
#pragma once

#include <fmt/format.h>
#include "account/coin_transaction_type.hpp"  // tam masz definicję enuma

template <>
struct fmt::formatter<CoinTransactionType> {
  // nie parsujemy żadnych dodatkowych flag:
  constexpr auto parse(fmt::format_parse_context& ctx) { return ctx.begin(); }

  template <typename FormatContext>
  auto format(CoinTransactionType type, FormatContext& ctx) {
    // mapujemy enum na string
    std::string_view name = "Unknown";
    switch (type) {
      case CoinTransactionType::Deposit:   name = "Deposit";   break;
      case CoinTransactionType::Withdraw:  name = "Withdraw";  break;
      case CoinTransactionType::Transfer:  name = "Transfer";  break;
      // ... kolejne wartości
    }
    return fmt::format_to(ctx.out(), "{}", name);
  }
};