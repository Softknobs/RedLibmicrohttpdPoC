Red [
	Title: libmicrohttpd serving one page with Red bindings	
	Author: Softknobs
	Version: 1.0
	Needs: 'view
]

upload: function [upload [binary!]][
	write/binary %upload upload
]

#system [	

	GET: 0
	POST: 1
	
	MHD_NO: 0
	MHD_YES: 1

	con-info!: alias struct! [ 
	  connection-type [integer!]
	  answer [c-string!]
	  post-processor [integer!]
	]

	callback!: alias function! [
		cls	[c-string!]
		connection 	[integer!]		
		url [byte-ptr!]
		method [c-string!]
		version [c-string!]
		upload [byte-ptr!]
		upload-size [pointer! [integer!]]
		con-cls [pointer! [integer!]]
		return: [integer!]
	]
						 
	post-data-iterator!: alias function! [
		cls [pointer! [integer!]]
		kind [integer!]
		key [c-string!]
		filename [byte-ptr!]
		content-type [byte-ptr!]
		encoding [byte-ptr!]
		data [byte-ptr!]
		off [integer!]
		size [byte-ptr!]
		return: [integer!]
	]

	post-iterator: function [
		[cdecl]
		cls [pointer! [integer!]]
		kind [integer!]
		key [c-string!]
		filename [byte-ptr!]
		content-type [byte-ptr!]
		encoding [byte-ptr!]
		data [byte-ptr!]
		off [integer!]
		size [byte-ptr!]
		return: [integer!]
		/local con-info value
	][
		con-info: as con-info! cls
		value: as c-string! data		
		if (((size? value) > 1)) [					
			print-line ["Field: " key " Value: " value]
		]
		
		either ((size? value) > 0)[
			con-info/answer: value
		][
			con-info/answer: ""
		]		
		
		return MHD_YES
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
			; PostProcessor functions
			lib-create-post-processor: "MHD_create_post_processor" [connection [integer!] buffer-size [integer!] post-data-iterator [post-data-iterator!] iter-cls [con-info!] return: [integer!]]
			lib-post-process: "MHD_post_process" [post-processor [integer!] post-data [byte-ptr!] post-data-length [pointer! [integer!]] return: [integer!]]			
			lib-destroy-post-processor: "MHD_destroy_post_processor " [post-processor [integer!] return: [integer!]]			
		]
	]	
		
	
	handler-callback: function [
		[cdecl]
		cls	[c-string!]
		connection 	[integer!]		
		url [byte-ptr!]
		method [c-string!]
		version [c-string!]
		upload [byte-ptr!]
		upload-size [pointer! [integer!]]
		con-cls [pointer! [integer!]]
		return: [integer!]
		/local html response-size response-number response-status red-upload con-info p
	][
					
		html: {
			<html><body>Print to console:<br><form enctype="multipart/form-data" method="post"><input name="name" type="text"><input type="submit" value=" Print "></form></body></html>
			}
		response-size: length? html
			
		if (con-cls/value = 0) [
			con-info: declare con-info!									
			
			either ((as integer! method/1) = 80) [		
				; Process first POST
				con-info/post-processor: lib-create-post-processor connection 512 :post-iterator con-info
				con-info/connection-type: POST								
				if (con-info/post-processor = 0) [
					return MHD_NO
				]
			][
				con-info/connection-type: GET
				; Process first GET
			]			
			con-cls/value: as integer! con-info
			return MHD_YES
		]
		
		if ((as integer! method/1) = 71) [
			; Process GET
			response-number: lib-create-buffer-response response-size html 0
			response-status: lib-queue-response connection 200 response-number
			lib-destroy-response response-number
			return response-status			
		]		
		
		if ((as integer! method/1) = 80) [		
			; Process POST
			con-info: as con-info! con-cls/value
			if (upload-size/value > 0) [
				lib-post-process con-info/post-processor upload upload-size
				upload-size/value: 0
				return MHD_YES
			]
		]
		
		response-number: lib-create-buffer-response response-size html 0
		response-status: lib-queue-response connection 500 response-number
		lib-destroy-response response-number
		
		return response-status
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
	lib-start-daemon 4 port 0 "" :handler-callback "" 0
]

stop: routine [daemon [integer!]][
	lib-stop-daemon daemon
]

daemon: none

libmicrohttpd-version: rejoin ["libmicrohttpd " version]

print libmicrohttpd-version

start 8080

print ["Press Ctrl-C to quit"]

forever []