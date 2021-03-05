#! /usr/bin/env python3

# Copyright 2021 Bastien Léonard

# This file is part of Dungeonesque Dungeons.

# Dungeonesque Dungeons is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.

# Dungeonesque Dungeons is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.

# You should have received a copy of the GNU General Public License along with
# Dungeonesque Dungeons. If not, see <https://www.gnu.org/licenses/>.

import os
from pathlib import Path
import sys


LICENSE_NOTICE = """
-- Copyright 2021 Bastien Léonard

-- This file is part of Dungeonesque Dungeons.

-- Dungeonesque Dungeons is free software: you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or (at your
-- option) any later version.

-- Dungeonesque Dungeons is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
-- more details.

-- You should have received a copy of the GNU General Public License along with
-- Dungeonesque Dungeons. If not, see <https://www.gnu.org/licenses/>.
""".strip()


def _check_file(path):
    any_errors = False
    file_content = None

    with open(path) as f:
        file_content = f.read()

    if not file_content.startswith(LICENSE_NOTICE):
        any_errors = True
        print('{}: file is missing license notice'.format(path))

    return any_errors

def main():
    any_errors = False

    # FIXME: only check the files currently in Git
    for root, dirs, filenames in os.walk('src'):
        for filename in filenames:
            path = Path(root, filename)

            if path.suffix == '.lua':
                result = _check_file(path)
                any_errors = any_errors or result

    return 1 if any_errors else 0


if __name__ == '__main__':
    sys.exit(main())
