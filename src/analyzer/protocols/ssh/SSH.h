// See the file "COPYING" in the main distribution directory for copyright.

#ifndef ssh_h
#define ssh_h

#include "analyzer/protocols/tcp/TCP.h"
#include "analyzer/protocols/tcp/ContentLine.h"

namespace analyzer { namespace ssh {

class SSH_Analyzer : public tcp::TCP_ApplicationAnalyzer {
public:
	SSH_Analyzer(Connection* conn);

	virtual void DeliverStream(int len, const u_char* data, bool orig);

	static analyzer::Analyzer* InstantiateAnalyzer(Connection* conn)
		{ return new SSH_Analyzer(conn); }

private:
	tcp::ContentLine_Analyzer* orig;
	tcp::ContentLine_Analyzer* resp;
};

} } // namespace analyzer::* 

#endif