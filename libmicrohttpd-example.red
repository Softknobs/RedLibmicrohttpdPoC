Red [
	Title: libmicrohttpd serving one page with Red bindings	
	Author: Softknobs
	Version: 1.0
	Needs: 'view
]

#system [	

	callback!: alias function! [
		cls	[c-string!]
		connection 	[integer!]		
		url [c-string!]
		method [c-string!]
		version [c-string!]
		upload [c-string!]
		upload-size [integer!]
		con-cls [c-string!]
		return: [integer!]
	]

	#switch OS [
		Windows		[
			#define libmicrohttpd-library "libmicrohttpd-12.dll"
		]
		Linux		[
			#define libmicrohttpd-library "libmicrohttpd.so.12"			
		]
	]
	#import [
		libmicrohttpd-library cdecl [
			lib-get-version: "MHD_get_version" [return: [c-string!]]
			lib-start-daemon: "MHD_start_daemon" [flags [integer!] port [integer!] policy-callback [integer!] extras-cls [c-string!] handler-callback [callback!] extras-dh [c-string!] options [integer!] return: [integer!]]
			lib-stop-daemon: "MHD_stop_daemon" [daemon [integer!]]			
			lib-create-buffer-response: "MHD_create_response_from_buffer" [size [integer!] data [c-string!] response-memory-mode [integer!] return: [integer!]]
			lib-queue-response: "MHD_queue_response" [connection [integer!] status [integer!] response [integer!] return: [integer!]]
			lib-destroy-response: "MHD_destroy_response" [response [integer!]]
		]
	]
		
	
	handler-callback: function [
		[cdecl]
		cls	[c-string!]
		connection 	[integer!]		
		url [c-string!]
		method [c-string!]
		version [c-string!]
		upload [c-string!]
		upload-size [integer!]
		con-cls [c-string!]
		return: [integer!]
		/local html response-size response-number response-status
	][
		html: "<html><body>Hello from libmicrohttpd with Red bindings</body></html>"
		response-size: length? html
		
		response-number: lib-create-buffer-response response-size html 0
		response-status: lib-queue-response connection 200 response-number
		lib-destroy-response response-number
		response-status
	]
		
]

version: routine [
	/local c-version
	return [red-string!]
][
	c-version: lib-get-version
	string/load c-version length? c-version UTF-8
]

start: routine [port [integer!] return: [integer!]][
	lib-start-daemon 8 port 0 "" :handler-callback "" 0
]

stop: routine [daemon [integer!]][
	lib-stop-daemon daemon
]

daemon: none

libmicrohttpd-version: rejoin ["libmicrohttpd " version]

switch system/platform [
	Windows [
		print "Windows"
		view [
			title "libmicrohttpd Red example"
			text libmicrohttpd-version 200
			return
			text "Port: "
			port: field data 8080
			return
			button "Start server" [if not daemon [daemon: start port/data]]
			button "Stop server" [if daemon [stop daemon daemon: none]]
		]		
	]
	Linux [
		print "Linux"
		print "Start server on port 8080"
		start 8080
		forever []
	]	
]
