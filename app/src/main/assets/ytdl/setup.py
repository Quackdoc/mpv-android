import sys, os, urllib.request

scriptdest = "../youtube-dl"
targets = {
	"youtube-dl": "https://youtube-dl.org/downloads/latest/youtube-dl",
	"yt-dlp": "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp",
}

# Clean up old files first
try:
	os.unlink(scriptdest)
except:
	pass
for name in targets.keys():
	try:
		os.unlink(name)
	except:
		pass

name = sys.argv[1].lower()
url = targets[name]
print("Downloading '%s'..." % url)
try:
	urllib.request.urlretrieve(url, name)
except urllib.error.HTTPError as e:
	print(e)
	exit(1)
except urllib.error.ContentTooShortError as e:
	print("Download interrupted!")
	exit(1)
print("OK.")

# Write wrapper script
with open(scriptdest, "w") as f:
	f.write("""#!/system/bin/sh\nexec "$(dirname "$0")/ytdl/wrapper" %s "$@"\n""" % name)
os.chmod(scriptdest, 0o700)
