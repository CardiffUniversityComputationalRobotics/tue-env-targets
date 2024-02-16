# Setup QtCreator

After installation the following still needs to be done to configure QtCreator with the tue environment:

1. Open QtCreator
2. Open Tools -> Options
3. Select the 'Build & Run' page on the left.
    - In the 'General' tab change projects directory to `%{Env:TUE_SYSTEM_DIR}/src`
    - In 'Default Build Properties' tab change 'Default build directory' to `%{Env:CURRENT_CMAKE_BUILD_DIR}/%{Project:Name}`

This matches the instructions from the [ROS Wiki](http://wiki.ros.org/IDEs#QtCreator)
