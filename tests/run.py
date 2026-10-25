from pathlib import Path
from lupa.lua54 import LuaRuntime
import os

root = Path(__file__).resolve().parents[1]
os.chdir(root)
lua = LuaRuntime()
for source in root.glob('*.lua'):
    source.read_bytes().decode('utf-8', errors='strict')
    lua.execute('assert(loadfile(...))', source.as_posix())
lua.execute(Path('tests/model.lua').read_text(encoding='utf-8'))
lua.execute(Path('tests/runtime.lua').read_text(encoding='utf-8'))
print('PASS: Lua syntax, sorting conservation and runtime interaction checks.')
