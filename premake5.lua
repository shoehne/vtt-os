workspace 'Vtt-Kernel'
    configurations {
        'debug',
        'release',
    }
    location 'build/'

    project 'Vtt-Kernel-x86_64'
        kind 'ConsoleApp'
        language 'C'
        toolset 'gcc'
        architecture 'x86_64'

        buildoptions {
            '--ffreestanding',
            '-m64',
            '-Wall',
            '-Wextra',
            '-nostdlib',
            '-fno-builtin',
            '-fno-stack-protector',
        }
        linkoptions {
            '-nostdlib',
            '-T ../source/x86_64/linker.ld',
        }
        targetextension '.bin'

        targetdir './bin/%{cfg.buildcfg}-%{cfg.architecture}'
        objdir './bin-obj/%{cfg.buildcfg}-%{cfg.architecture}'

        prebuildcommands {
            'mkdir -p %{cfg.objdir}',
            'mkdir -p %{cfg.targetdir}',
        }

        includedirs {
            'include',
        }

        files {
            'source/kernel/**.c',
            'source/x86_64/*.c',
            'source/x86_64/*.asm',
            'source/x86_64/*.ld',
        }

        filter { "files:**.asm" }
            buildmessage 'Assembling %{file.relpath}'
            buildcommands {
                'nasm -f elf64 %{file.relpath} -o %{cfg.objdir}/%{file.basename}.o'
            }
            buildoutputs {
                '%{cfg.objdir}/%{file.basename}.o'
            }
