#ifndef __SRC_KV_VALUE_WRAPPER_PROTO_HPP_
#define __SRC_KV_VALUE_WRAPPER_PROTO_HPP_

#include "pch.hpp"
#include <parallel_hashmap/phmap.h>
#include <map>
#include <vector>
#include <cstdint>
#include <string>
#include <memory>

#include <cstdint>
#include <string>
#include <memory>

/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#pragma once

class ValueWrapper;

using StringType = std::string;
using BooleanType = bool;
using IntType = int;
using DoubleType = double;
using ArrayType = std::vector<ValueWrapper>;
using MapType = phmap::flat_hash_map<std::string, std::shared_ptr<ValueWrapper>>;

using ValueVariant = std::variant<StringType, BooleanType, IntType, DoubleType, ArrayType, MapType>;

// Forward declaration for protobuf class
namespace Canary::protobuf::kv {
	class ValueWrapper;
}

struct ProtoSerializable {
	static Canary::protobuf::kv::ValueWrapper toProto(const ValueWrapper &obj);
	static ValueWrapper fromProto(const Canary::protobuf::kv::ValueWrapper &protoValue, uint64_t timestamp);
};

namespace ProtoHelpers {
	void setProtoStringValue(Canary::protobuf::kv::ValueWrapper &protoValue, const StringType &arg);
	void setProtoBooleanValue(Canary::protobuf::kv::ValueWrapper &protoValue, const BooleanType &arg);
	void setProtoIntValue(Canary::protobuf::kv::ValueWrapper &protoValue, const IntType &arg);
	void setProtoDoubleValue(Canary::protobuf::kv::ValueWrapper &protoValue, const DoubleType &arg);
	void setProtoArrayValue(Canary::protobuf::kv::ValueWrapper &protoValue, const ArrayType &arg);
	void setProtoMapValue(Canary::protobuf::kv::ValueWrapper &protoValue, const MapType &arg);
}

#endif // __SRC_KV_VALUE_WRAPPER_PROTO_HPP_
