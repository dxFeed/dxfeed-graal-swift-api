# Prerequisite:
- java
- gradle
- Xcode

## Java
install OpenJDK

## Gradle
`brew install gradle`

# Next step
## Download graal artifacts:
`gradle fetchDependencies` 

Gradle downloads artifacts and unzip it in `graal_builds` folder

# Working this code
Project has 2 targets: 
- DXFramework 
  Use it for testing your code and build framework for active arch.
- XCFramework
  Use if for building fat-xcframework for all platforms(iOS Arm, macOS Arm, macOS Intel)
