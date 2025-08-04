workspace 'Vtt-Kernel'
    configurations {
        'debug',
        'release',
    }
    location 'build/'

    project 'Vtt-Kernel-x86_64'
        kind 'Makefile'
        language 'C'
        toolset 'gcc'
        architecture 'x86_64'
        buildoptions {
            '--ffreestanding',
            '-m64',
        }
        linkoptions {
            '-nostdlib',
            '-T source/x86_64/linker.ld',
        }
        targetextension '.bin'

        targetdir '../bin/%{cfg.buildcfg}-%{cfg.architecture}'
        objdir '../bin-obj/%{cfg.buildcfg}-%{cfg.architecture}'

        includedirs {
            'include',
        }

        files {
            'source/kernel/**.c',
            'source/x86_64/*.c',
            'source/x86_64/*.S',
            'source/x86_64/*.ld',
        }
