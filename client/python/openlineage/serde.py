# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import json
from enum import Enum
from typing import List, Dict

import attr


class EventEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Enum):
            return obj.value
        if obj is None:
            return
        return super().default(obj)


class Serde:
    @classmethod
    def remove_nulls(cls, obj):
        if isinstance(obj, Dict):
            return dict(filter(
                lambda x: x[1] is not None,
                {k: cls.remove_nulls(v) for k, v in obj.items()}.items()
            ))
        if isinstance(obj, List):
            return list(filter(lambda x: x is not None and x != {}, [
                cls.remove_nulls(v) for v in obj if v is not None
            ]))
        return obj

    @classmethod
    def to_json(cls, obj):
        dicted = attr.asdict(obj)
        without_nulls = cls.remove_nulls(dicted)
        return json.dumps(without_nulls, cls=EventEncoder, sort_keys=True)
