
message(STATUS "Installing the Python wrapper...")

add_custom_target(ALL COMMAND make run
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
