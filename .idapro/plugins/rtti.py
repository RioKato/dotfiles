from typing import Any
from idaapi import UI_Hooks


def binfmt_32_or_64(bit32: str, bit64: str):
    from idaapi import get_inf_structure

    inf = get_inf_structure()

    if inf.is_64bit():
        return bit64
    else:
        return bit32


def cpu_intel_or_arm(intel: int, arm: int):
    from idaapi import get_inf_structure

    inf = get_inf_structure()

    if inf.procname == 'ARM':
        return arm

    return intel


VTABLE_HEADER = binfmt_32_or_64('iI', 'qQ')
VTABLE_POINTER = binfmt_32_or_64('I', 'Q')
CLASS_TYPE_INFO = binfmt_32_or_64('II', 'QQ')
SI_CLASS_TYPE_INFO = binfmt_32_or_64('III', 'QQQ')
VMI_CLASS_TYPE_INFO = binfmt_32_or_64('IIII', 'QQII')
BASE_CLASS_TYPE_INFO = binfmt_32_or_64('II', 'QQ')
VTABLE_NAME_PATTERN = r"`vtable for'(.+)"
TYPEINFO_NAME_PATTERN = r"`typeinfo for'(.+)"
MANGLED_NAME_VTABLE_CLASS_TYPE_INFO = "_ZTVN10__cxxabiv117__class_type_infoE"
MANGLED_NAME_VTABLE_SI_CLASS_TYPE_INFO = "_ZTVN10__cxxabiv120__si_class_type_infoE"
MANGLED_NAME_VTABLE_VMI_CLASS_TYPE_INFO = "_ZTVN10__cxxabiv121__vmi_class_type_infoE"
FUNCTION_POINTER_MASK = cpu_intel_or_arm(0, 1)


def get_unpacked(ea: int, fmt: str) -> Any:
    from struct import unpack, calcsize
    from idaapi import get_bytes

    size = calcsize(fmt)
    data = get_bytes(ea, size)
    return (ea+size,)+unpack(fmt, data)


def parse_typeinfo(ea: int) -> dict[int, str]:
    from struct import calcsize
    from idc import BADADDR, get_name_ea_simple

    vtable_class_type_info = get_name_ea_simple(
        MANGLED_NAME_VTABLE_CLASS_TYPE_INFO)
    if vtable_class_type_info == BADADDR:
        print('[RTTI] vtable_class_type_info not found')

    vtable_si_class_type_info = get_name_ea_simple(
        MANGLED_NAME_VTABLE_SI_CLASS_TYPE_INFO)
    if vtable_si_class_type_info == BADADDR:
        print('[RTTI] vtable_si_class_type_info not found')

    vtable_vmi_class_type_info = get_name_ea_simple(
        MANGLED_NAME_VTABLE_VMI_CLASS_TYPE_INFO)
    if vtable_vmi_class_type_info == BADADDR:
        print('[RTTI] vtable_vmi_class_type_info not found')

    def create_name(ea: int):
        from re import fullmatch
        from idaapi import INF_SHORT_DEMNAMES, get_name, demangle_name
        if name := get_name(ea):
            if name := demangle_name(name, INF_SHORT_DEMNAMES):
                if match := fullmatch(TYPEINFO_NAME_PATTERN, name):
                    return match.group(1)

        return f'ADDR_{ea:X}'

    _, vtable, _ = get_unpacked(ea, CLASS_TYPE_INFO)
    # vtable -= calcsize(VTABLE_HEADER)
    assert (vtable in
            [vtable_class_type_info, vtable_si_class_type_info, vtable_vmi_class_type_info])

    if vtable == vtable_class_type_info:
        return {0: create_name(ea)}

    elif vtable == vtable_si_class_type_info:
        _, _, _, base_type = get_unpacked(ea, SI_CLASS_TYPE_INFO)
        return {0: create_name(base_type)}

    elif vtable == vtable_vmi_class_type_info:
        ea, _, _, _, base_count = get_unpacked(ea, VMI_CLASS_TYPE_INFO)

        typeinfo = {}
        for _ in range(base_count):
            ea, base_type, offset_flags = get_unpacked(
                ea, BASE_CLASS_TYPE_INFO)
            typeinfo[offset_flags >> 8] = create_name(base_type)

        return typeinfo

    raise ValueError


def parse_vtable(start_ea: int, end_ea: int, typeinfo: dict[int, str]) -> dict[str, tuple[int, int]]:
    from struct import calcsize
    from idaapi import get_segm_by_name

    text = get_segm_by_name('.text')
    extern = get_segm_by_name('extern')
    ea = start_ea
    vtable = {}

    for _ in typeinfo:
        head_ea = ea

        assert (ea + calcsize(VTABLE_HEADER) <= end_ea)
        ea, ofs, _ = get_unpacked(ea, VTABLE_HEADER)
        assert (-ofs in typeinfo)

        while ea < end_ea:
            next_ea, ptr = get_unpacked(ea, VTABLE_POINTER)

            if not text.start_ea <= ptr < text.end_ea and not extern.start_ea <= ptr < extern.end_ea:
                break

            ea = next_ea

        vtable[typeinfo[-ofs]] = (head_ea, ea)

    assert (ea == end_ea)

    return vtable


def create_vtable(name: str, start_ea: int, end_ea: int):
    from contextlib import suppress
    from struct import calcsize
    from idaapi import BADADDR, FF_DWORD, FF_QWORD, get_struc_id, get_struc, add_struc, get_max_offset, add_struc_member, del_struc_members, set_member_tinfo, tinfo_t, get_tinfo
    from ida_hexrays import DECOMP_NO_CACHE, decompile
    from idc import apply_type, parse_decl

    start_ea += calcsize(VTABLE_HEADER)
    assert (start_ea <= end_ea)

    sid = get_struc_id(name)

    if sid != BADADDR:
        struc = get_struc(sid)
        del_struc_members(struc, 0, get_max_offset(struc))
    else:
        sid = add_struc(-1, name)
        struc = get_struc(sid)

    size = calcsize(VTABLE_POINTER)
    flag = {
        4: FF_DWORD,
        8: FF_QWORD
    }[size]

    ea = start_ea
    i = 0

    while ea < end_ea:
        ea, ptr = get_unpacked(ea, VTABLE_POINTER)
        ptr -= ptr & FUNCTION_POINTER_MASK
        add_struc_member(
            struc, f'virtual{i}_{ptr:X}', BADADDR, flag, None, size)

        with suppress(Exception):
            decompile(ptr, flags=DECOMP_NO_CACHE)

        ti_fun = tinfo_t()
        if get_tinfo(ti_fun, ptr):
            ti_funptr = tinfo_t()
            ti_funptr.create_ptr(ti_fun)
            set_member_tinfo(struc, struc.get_last_member(), 0, ti_funptr, 0)

        i += 1

    apply_type(start_ea, parse_decl(name, 0), 0)


def popup_main(start_ea: int, end_ea: int):
    from re import fullmatch
    from struct import calcsize
    from idaapi import INF_SHORT_DEMNAMES, get_name, demangle_name

    name = get_name(start_ea)
    assert (name)
    name = demangle_name(name, INF_SHORT_DEMNAMES)
    assert (name)
    match = fullmatch(VTABLE_NAME_PATTERN, name)
    assert (match)
    name = match.group(1)

    assert (start_ea + calcsize(VTABLE_HEADER) <= end_ea)

    _, ofs, typeinfo_ea = get_unpacked(start_ea, VTABLE_HEADER)
    assert (ofs == 0)

    typeinfo = parse_typeinfo(typeinfo_ea)
    print(f'[RTTI] typeinfo = {typeinfo}')

    vtable = parse_vtable(start_ea, end_ea, typeinfo)
    print(f'[RTTI] vtable = {vtable}')

    for subname, (start_ea, end_ea) in vtable.items():
        create_vtable(f'{name}::{subname}::vtable', start_ea, end_ea)


class PopupHooks(UI_Hooks):
    def finish_populating_widget_popup(self, form, popup):
        from idaapi import BWN_DISASMS, SETMENU_INS, get_widget_type, action_handler_t, action_desc_t, attach_dynamic_action_to_popup

        if get_widget_type(form) == BWN_DISASMS:

            class handler(action_handler_t):
                def activate(self, _):
                    from idaapi import read_range_selection

                    ok, start_ea, end_ea = read_range_selection(None)
                    if ok:
                        popup_main(start_ea, end_ea)

            name = 'Create vtable from selection'
            desc = action_desc_t(None, name, handler())
            attach_dynamic_action_to_popup(
                form, popup, desc, name, SETMENU_INS)


hooks = PopupHooks()
hooks.hook()


############################################################################


def typeinfo_paths() -> set[tuple[str, str, bool]]:
    from struct import calcsize
    from re import fullmatch
    from idautils import Names
    from idaapi import INF_SHORT_DEMNAMES, get_name, demangle_name
    from idc import BADADDR, get_name_ea_simple

    vtable_si_class_type_info = get_name_ea_simple(
        MANGLED_NAME_VTABLE_SI_CLASS_TYPE_INFO)
    assert (vtable_si_class_type_info != BADADDR)

    vtable_vmi_class_type_info = get_name_ea_simple(
        MANGLED_NAME_VTABLE_VMI_CLASS_TYPE_INFO)
    assert (vtable_vmi_class_type_info != BADADDR)

    paths = set()

    for ea, child in Names():
        if child := demangle_name(child, INF_SHORT_DEMNAMES):
            if match := fullmatch(TYPEINFO_NAME_PATTERN, child):
                child = match.group(1)

                _, vtable, _ = get_unpacked(ea, CLASS_TYPE_INFO)
                vtable -= calcsize(VTABLE_HEADER)

                if vtable == vtable_si_class_type_info:
                    _, _, _, base_type = get_unpacked(ea, SI_CLASS_TYPE_INFO)

                    if paren := get_name(base_type):
                        if paren := demangle_name(paren, INF_SHORT_DEMNAMES):
                            if match := fullmatch(TYPEINFO_NAME_PATTERN, paren):
                                paren = match.group(1)
                                paths.add((paren, child, True))

                elif vtable == vtable_vmi_class_type_info:
                    ea, _, _, _, base_count = get_unpacked(
                        ea, VMI_CLASS_TYPE_INFO)

                    primary = True

                    for _ in range(base_count):
                        ea, base_type, _ = get_unpacked(
                            ea, BASE_CLASS_TYPE_INFO)

                        if paren := get_name(base_type):
                            if paren := demangle_name(paren, INF_SHORT_DEMNAMES):
                                if match := fullmatch(TYPEINFO_NAME_PATTERN, paren):
                                    paren = match.group(1)
                                    paths.add((paren, child, primary))
                                    primary = False

    return paths


def typeinfo_graphiz(file: str):
    with open(file, 'w') as fd:
        print('digraph {', file=fd)

        for (src, dst, primary) in typeinfo_paths():
            if primary:
                arrow = f'"{src}" -> "{dst}"'
            else:
                arrow = f'"{src}" -> "{dst}" [style="dotted"]'

            print(arrow, file=fd)

        print('}', file=fd)


def PLUGIN_ENTRY():
    from idaapi import PLUGIN_UNL, PLUGIN_OK, plugin_t, ask_file

    class RTTIPlugin(plugin_t):
        flags = PLUGIN_UNL
        wanted_name = 'Create graph by RTTI'

        def init(self):
            return PLUGIN_OK

        def run(self, _):
            file = ask_file(0, '~', 'typeinfo_graphiz')
            typeinfo_graphiz(file)

        def term(self):
            pass

    return RTTIPlugin()
