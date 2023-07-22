profile = Release
profile_lower = $(shell echo $(profile) | tr A-Z a-z)

hello:
	echo $(profile_lower)
