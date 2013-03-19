# @TEST-EXEC: bro -r $TRACES/http/206_example_a.pcap %INPUT >a.out
# @TEST-EXEC: btest-diff a.out
# @TEST-EXEC: wc -c uj9AtyGOiZ8-file0 >a.size
# @TEST-EXEC: btest-diff a.size

# @TEST-EXEC: bro -r $TRACES/http/206_example_b.pcap %INPUT >b.out
# @TEST-EXEC: btest-diff b.out
# @TEST-EXEC: wc -c ns7As4DOZcj-file0 >b.size
# @TEST-EXEC: btest-diff b.size

# @TEST-EXEC: bro -r $TRACES/http/206_example_c.pcap %INPUT >c.out
# @TEST-EXEC: btest-diff c.out
# @TEST-EXEC: wc -c MHMkq2nFxej-file0 >c.size
# @TEST-EXEC: btest-diff c.size

global actions: set[FileAnalysis::ActionArgs];
global cnt: count = 0;

hook FileAnalysis::policy(trig: FileAnalysis::Trigger, info: FileAnalysis::Info)
	{
	print trig;

	switch ( trig ) {
	case FileAnalysis::TRIGGER_NEW:
		print info$file_id, info$seen_bytes, info$missing_bytes;

		if ( info$source == "HTTP" )
			{
			for ( act in actions )
				FileAnalysis::add_action(info$file_id, act);
			local filename: string = fmt("%s-file%d", info$file_id, cnt);
			++cnt;
			FileAnalysis::add_action(info$file_id,
			                         [$act=FileAnalysis::ACTION_EXTRACT,
			                          $extract_filename=filename]);
			}
		break;

	case FileAnalysis::TRIGGER_BOF_BUFFER:
		if ( info?$bof_buffer )
			print info$bof_buffer[0:10];
		break;

	case FileAnalysis::TRIGGER_TYPE:
		# not actually printing the values due to libmagic variances
		if ( info?$file_type )
			print "file type is set";
		if ( info?$mime_type )
			print "mime type is set";
		break;

	case FileAnalysis::TRIGGER_EOF:
		fallthrough;
	case FileAnalysis::TRIGGER_DONE:

		print info$file_id, info$seen_bytes, info$missing_bytes;
		print info$conn_uids;
		print info$conn_ids;

		if ( info?$total_bytes )
			print "total bytes: " + fmt("%s", info$total_bytes);
		if ( info?$source )
			print "source: " + info$source;

		for ( act in info$actions )
			switch ( act$act ) {
			case FileAnalysis::ACTION_MD5:
				if ( info$actions[act]?$md5 )
					print fmt("MD5: %s", info$actions[act]$md5);
				break;
			case FileAnalysis::ACTION_SHA1:
				if ( info$actions[act]?$sha1 )
					print fmt("SHA1: %s", info$actions[act]$sha1);
				break;
			case FileAnalysis::ACTION_SHA256:
				if ( info$actions[act]?$sha256 )
					print fmt("SHA256: %s", info$actions[act]$sha256);
				break;
			}
		break;
	}
	}

event bro_init()
	{
	add actions[[$act=FileAnalysis::ACTION_MD5]];
	add actions[[$act=FileAnalysis::ACTION_SHA1]];
	add actions[[$act=FileAnalysis::ACTION_SHA256]];
	}