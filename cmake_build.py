from __future__ import print_function
import argparse
import sys
import os.path
import subprocess
import shutil

# -----------------------------------------------------------------------------
# Platform build options
# -----------------------------------------------------------------------------

GENERATORS = 'generators'
GENERATOR_SHORT_NAME = 'short_name'
GENERATOR_NAME = 'name'
GENERATOR_STR = 'string'
GENERATOR_PATH = 'path'
GENERATOR_BUILD_DIR = 'build_dir'
TOOLSETS = 'toolsets'
TOOLSET_NAME = 'toolset_name'
TOOLSET_STR = 'toolset_str'
CMAKE_COMMAND = 'cmake'
CMAKE_COMMAND_RELATIVE = 'cmake_rel'

PLATFORM_OPTS = {
    # -----------------------------------------------------------------------------
    # Linux
    # -----------------------------------------------------------------------------
    'linux2': {
        GENERATORS: [
                {
                    GENERATOR_SHORT_NAME: 'make',
                    GENERATOR_NAME: 'make',
                    GENERATOR_STR: 'Unix Makefiles',
                    GENERATOR_BUILD_DIR: 'linux',
                    TOOLSETS: []
                }
        ],
        CMAKE_COMMAND: 'cmake',
        CMAKE_COMMAND_RELATIVE: False
    },
    'linux': {
        GENERATORS: [
            {
                GENERATOR_SHORT_NAME: 'make',
                GENERATOR_NAME: 'make',
                GENERATOR_STR: 'Unix Makefiles',
                GENERATOR_BUILD_DIR: 'linux',
                TOOLSETS: []
            }
        ],
        CMAKE_COMMAND: 'cmake',
        CMAKE_COMMAND_RELATIVE: False
    },

    # -----------------------------------------------------------------------------
    # Windows
    # -----------------------------------------------------------------------------
    'win32': {
        GENERATORS: [
            {
                GENERATOR_SHORT_NAME: 'vs2019',
                GENERATOR_NAME: 'Visual Studio 2019',
                GENERATOR_STR: 'Visual Studio 16 2019',
                GENERATOR_BUILD_DIR: 'win64',
                TOOLSETS: [
                ]
            },
            {
                GENERATOR_SHORT_NAME: 'vs2017 32bit',
                GENERATOR_NAME: 'Visual Studio 2017 32bit',
                GENERATOR_STR: 'Visual Studio 15 2017',
                GENERATOR_BUILD_DIR: 'win32',
                TOOLSETS: [
                ]
            },
            {
                GENERATOR_SHORT_NAME: 'vs2017',
                GENERATOR_NAME: 'Visual Studio 2017 64bit',
                GENERATOR_STR: 'Visual Studio 15 2017 Win64',
                GENERATOR_BUILD_DIR: 'win64',
                TOOLSETS: [
                ]
            }
        ],
        CMAKE_COMMAND: 'tools/bin/cmake/bin/cmake.exe',
        CMAKE_COMMAND_RELATIVE: True
    },

    # -----------------------------------------------------------------------------
    # Apple OS X
    # -----------------------------------------------------------------------------
    'darwin': {
        GENERATORS: [
            {
                GENERATOR_SHORT_NAME: 'sublime',
                GENERATOR_NAME: 'Sublime Text',
                GENERATOR_STR: 'Sublime Text 2 - Unix Makefiles',
                GENERATOR_BUILD_DIR: 'osx',
                TOOLSETS: []
            },
            {
                GENERATOR_SHORT_NAME: 'xcode',
                GENERATOR_NAME: 'Xcode',
                GENERATOR_STR: 'Xcode',
                GENERATOR_BUILD_DIR: 'osx',
                TOOLSETS: []
            },
            {
                GENERATOR_SHORT_NAME: 'ninja',
                GENERATOR_NAME: 'ninja',
                GENERATOR_STR: 'Ninja',
                GENERATOR_BUILD_DIR: 'osx',
                TOOLSETS: []
            }
        ],
        CMAKE_COMMAND: 'cmake',
        CMAKE_COMMAND_RELATIVE: False
    },
}

# -----------------------------------------------------------------------------
# Find the generator specified by the given short form of its name
# -----------------------------------------------------------------------------


def find_generator_from_short_name(name):
    for p in PLATFORM_OPTS.values():
        for g in p[GENERATORS]:
            if g[GENERATOR_SHORT_NAME] == name:
                return g

    return None

# -----------------------------------------------------------------------------
# On error exit
# -----------------------------------------------------------------------------


def error(msg, print_help=False):
    print(msg)
    if print_help:
        print(parser.print_help())
    sys.exit(1)

# -----------------------------------------------------------------------------
# Process command line and setup globals
# -----------------------------------------------------------------------------


Platform = ''
PlatformOpts = None
GeneratorName = ''
Clean = False
ScriptDir = os.path.dirname(os.path.realpath(__file__)) + os.sep
BaseDir = os.path.dirname(os.path.realpath(__file__)) + os.sep


if not sys.platform in PLATFORM_OPTS:
    error("Platform not supported : " + sys.platform)

Platform = sys.platform
PlatformOpts = PLATFORM_OPTS[Platform]
PlatformGenerators = PlatformOpts[GENERATORS]
PlatformGeneratorsText = 'Available Generators\n'

for pg in PlatformGenerators:
    PlatformGeneratorsText += '  %s : %s\n' % (
        pg[GENERATOR_SHORT_NAME], pg[GENERATOR_NAME])

parser = argparse.ArgumentParser(description='Tycho cmake build',
                                 epilog=PlatformGeneratorsText,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)

parser.add_argument('-g', '--generator', help='generator to build')
parser.add_argument(
    '-c', '--clean', help='deleting existing build tree before generating', action='store_true')
parser.add_argument(
    'base_dir', help='base directory to place output directories in')
args = parser.parse_args()

if args.base_dir:
    BaseDir = args.base_dir

if args.clean:
    Clean = True

if args.generator:
    GeneratorName = args.generator

# get generator interactively if none specified
Generator = None
Toolset = None
Selections = []
if GeneratorName == None or len(GeneratorName) == 0:
    # if only one generator available then select that
    if len(PlatformGenerators) == 1:
        Generator = PlatformGenerators[0]
    else:
        i = 1
        print("--------------------")
        print("Available Generators")
        print("--------------------")
        for g in PlatformGenerators:
            name = g[GENERATOR_NAME]
            print("%s) %s" % (str(i), name))
            Selections.append([g, None])
            i += 1
            for t in g[TOOLSETS]:
                print("%s) %s - %s" % (str(i), name, t[TOOLSET_STR]))
                Selections.append([g, t])
                i += 1
        try:
            #			for s in Selections:
            #				print("s : %s" % s[0])
            index = int(input("Select Generator : ")) - 1
            if index < len(Selections):
                Generator = Selections[index][0]
                Toolset = Selections[index][1]
        except:
            print('Invalid selection')
            exit(1)
else:
    Generator = find_generator_from_short_name(GeneratorName)

if Generator == None:
    error("Failed to find generator : " + GeneratorName)

Generator[GENERATOR_PATH] = os.path.join(
    BaseDir, "build", Generator[GENERATOR_BUILD_DIR], Generator[GENERATOR_SHORT_NAME])
CMakeCommand = PlatformOpts[CMAKE_COMMAND]
if PlatformOpts[CMAKE_COMMAND_RELATIVE]:
    CMakeCommand = os.path.join(ScriptDir, CMakeCommand)
CMakeCmdLine = [CMakeCommand]
if Toolset != None:
    CMakeCmdLine.extend(['-T', Toolset[TOOLSET_NAME]])

CMakeCmdLine.extend([ ' -DCMAKE_BUILD_TYPE=Debug'])                     

CMakeCmdLine.extend(['-G', Generator[GENERATOR_STR],
                     str("..%s..%s..%s" % (os.sep, os.sep, os.sep))])

print("Base Directory   : " + BaseDir)
print("Script Directory : " + ScriptDir)
print("Platform         : " + Platform)
print("Generator        : " + Generator[GENERATOR_NAME])

if Toolset == None:
    print("Toolset	      : {default}")
else:
    print("Toolset	      : " + Toolset[TOOLSET_NAME])

print("Generator Dir  : " + Generator[GENERATOR_PATH])
print("Clean          : %s" % (Clean))
print("CMake Command  : %s" % (CMakeCmdLine))

# -----------------------------------------------------------------------------
# Generate project files
# -----------------------------------------------------------------------------
OutputPath = Generator[GENERATOR_PATH]

# remove all files if clean
if Clean and os.path.exists(OutputPath):
    shutil.rmtree(OutputPath)

# make sure directory exists
if not os.path.exists(OutputPath):
    os.makedirs(OutputPath)

# must run cmake from that directory to generate an out of source build
os.chdir(Generator[GENERATOR_PATH])

# finally actually run cmake
subprocess.call(CMakeCmdLine, shell=False)
