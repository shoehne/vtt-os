workspace 'Vtt-Kernel'
    configurations {
        'Debug',
        'Release',
    }
    location 'build/'

    project 'Vtt-Kernel'
        kind 'Makefile'
        language 'C'
        toolset 'gcc'
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
