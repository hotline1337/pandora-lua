-- wip
local ffi = require("ffi")

local og_func = nil
ffi.cdef[[
    int VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
    void* VirtualAlloc(void* lpAddress, unsigned long dwSize, unsigned long  flAllocationType, unsigned long flProtect);
    int VirtualFree(void* lpAddress, unsigned long dwSize, unsigned long dwFreeType);

    typedef struct
    {
        float x;
        float y;
        float z;
    } Vector_t;
]]

local ffi_helpers = {
    copy = function(dst, src, len)
        return ffi.copy(ffi.cast('void*', dst), ffi.cast('const void*', src), len)
    end,
    virtual_protect = function(lpAddress, dwSize, flNewProtect, lpflOldProtect)
        return ffi.C.VirtualProtect(ffi.cast('void*', lpAddress), dwSize, flNewProtect, lpflOldProtect)
    end,
    virtual_alloc = function(lpAddress, dwSize, flAllocationType, flProtect, blFree)
        local alloc = ffi.C.VirtualAlloc(lpAddress, dwSize, flAllocationType, flProtect)
        if blFree then
            table.insert(buff.free, function()
                ffi.C.VirtualFree(alloc, 0, 0x8000)
            end)
        end
        return ffi.cast('intptr_t', alloc)
    end
}

local vmt_hook = {hooks = {}}
function vmt_hook.new(vt)
    local new_hook = {}
    local org_func = {}
    local old_prot = ffi.new('unsigned long[1]')
    local virtual_table = ffi.cast('intptr_t**', vt)[0]
    new_hook.this = virtual_table
    new_hook.hookMethod = function(cast, func, method)
        org_func[method] = virtual_table[method]
        ffi_helpers:virtual_protect(virtual_table + method, 4, 0x4, old_prot)
        virtual_table[method] = ffi.cast('intptr_t', ffi.cast(cast, func))
        ffi_helpers:virtual_protect(virtual_table + method, 4, old_prot[0], old_prot)
        return ffi.cast(cast, org_func[method])
    end
    new_hook.unHookMethod = function(method)
        ffi_helpers:virtual_protect(virtual_table + method, 4, 0x4, old_prot)
        -- virtual_table[method] = org_func[method]
        local alloc_addr = ffi_helpers:virtual_alloc(nil, 5, 0x1000, 0x40, false)
        local trampoline_bytes = ffi.new('uint8_t[?]', 5, 0x90)
        trampoline_bytes[0] = 0xE9
        ffi.cast('int32_t*', trampoline_bytes + 1)[0] = org_func[method] - tonumber(alloc_addr) - 5
        ffi_helpers:copy(alloc_addr, trampoline_bytes, 5)
        virtual_table[method] = ffi.cast('intptr_t', alloc_addr)
        ffi_helpers:virtual_protect(virtual_table + method, 4, old_prot[0], old_prot)
        org_func[method] = nil
    end
    new_hook.unHookAll = function()
        for method, func in pairs(org_func) do
            new_hook.unHookMethod(method)
        end
    end
    table.insert(vmt_hook.hooks, new_hook.unHookAll)
    return new_hook
end

local CMInt = client.create_interface("client.dll", "VClient018")
local Client = vmt_hook.new(CMInt)

function emit_sound_hook(_this, edx, filter, iEntIndex, iChannel, pSoundEntry, nSoundEntryHash, pSample, flVolume, nSeed, flAttenuation, iFlags, iPitch, pOrigin, pDirection, pUtlVecOrigins, bUpdatePositions, soundtime, speakerentity, unk)
    if pSoundEntry == "UIPanorama.popup_accept_match_beep" then
        local fnAccept = ffi.cast("bool(__stdcall*)(const char*)", client.find_sig("client.dll", "55 8B EC 83 E4 F8 8B 4D 08 BA ? ? ? ? E8 ? ? ? ? 85 C0 75 12"))
        if fnAccept ~= nil then
            fnAccept("")
        end
    end
    og_func(_this, edx, filter, iEntIndex, iChannel, pSoundEntry, nSoundEntryHash, pSample, flVolume, nSeed, flAttenuation, iFlags, iPitch, pOrigin, pDirection, pUtlVecOrigins, bUpdatePositions, soundtime, speakerentity, unk)
end

og_func = Client.hookMethod("void(__fastcall*)(void* _this, int edx, void* filter, int iEntIndex, int iChannel, const char* pSoundEntry, unsigned int nSoundEntryHash, const char *pSample, float flVolume, int nSeed, float flAttenuation, int iFlags, int iPitch, void* pOrigin, void* pDirection, void* pUtlVecOrigins, bool bUpdatePositions, float soundtime, int speakerentity, int unk)", emit_sound_hook, 5)

