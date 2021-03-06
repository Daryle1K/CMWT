<!-- #include file=_core.asp -->
<%
'-----------------------------------------------------------------------------
' filename....... compstatus.asp
' lastupdate..... 12/29/2016
' description.... component status summary
'-----------------------------------------------------------------------------
time1 = Timer

FilterFN  = CMWT_GET("fn", "")
FilterFV  = CMWT_GET("fv", "")
QueryOn   = CMWT_GET("qq", "")

PageTitle    = "Component Status"
PageBackLink = "cmsite.asp"
PageBackName = "Site Hierarchy"

CMWT_NewPage "", "", ""
%>
<!-- #include file="_sm.asp" -->
<!-- #include file="_banner.asp" -->
<%
Sub CMWT_DB_IntTableGrid (rs, Caption, LinkField, LinkQualifier)
	Dim xrows, xcols, fn, fv, i 
	if not (rs.BOF and rs.EOF) then 
		xrows = rs.RecordCount 
		xcols = rs.Fields.Count
		Response.Write "<h2 class=""tfx"">" & Caption & "</h2>"
		Response.Write "<table class=""tfx""><tr>"
		for i = 0 to xcols -1
			fn = rs.fields(i).name
			Select Case Ucase(fn)
				Case "QTY","RECS","COUNT","MEMBERS","GROUPCOUNT","COMPUTERS","CLIENTS","COVERAGE":
					Response.Write "<td class=""td6 v10 bgGray w80 " & CMWT_DB_ColumnJustify(fn) & """>"
				Case Else:
					Response.Write "<td class=""td6 v10 bgGray"">"
			End Select
			Response.Write CMWT_SORTLINK("compstatus.asp", fn, SortBy) & "</td>"
		next
		Response.Write "</tr>"
		Do Until rs.EOF
			Response.Write "<tr class=""tr1"">"
			For i = 0 to xcols-1
				fn = rs.Fields(i).Name
				fv = rs.Fields(i).Value
				If Ucase(LinkField) = Ucase(fn) Then
					fv = "<a href=""compstatus2.asp?fn=" & LinkField & "&fv=" & fv & "&lq=" & LinkQualifier & _
						""" title=""Show Details"">" & fv & "</a>"
				End If
				Response.Write "<td class=""td6 v10 " & CMWT_DB_ColumnJustify(fn) & """>" & fv & "</td>"
			next
			rs.MoveNext
		Loop
		Response.Write "<tr>" & _
			"<td class=""td6 v10 bgGray"" colspan=""" & xcols+1 & """>" & _
			xrows & " rows returned</td></tr></table>"
	end if
End Sub

Dim conn, cmd, rs

query = "SELECT com.SiteCode, com.MachineName, stat.MessageID, com.ComponentName,  COUNT(*) as 'Error Count' " & _
	"FROM v_StatusMessage stat " & _
	"JOIN v_ServerComponents com on stat.SiteCode=com.SiteCode AND stat.MachineName=com.MachineName AND stat.Component=com.ComponentName " & _
	"WHERE Time > DATEADD(ss,-240-(24*3600),GetDate()) AND Severity='-1073741824' " & _
	"GROUP BY com.SiteCode, com.MachineName, com.ComponentName,stat.MessageID " & _
	"ORDER BY COUNT(*) DESC"
CMWT_DB_QUERY Application("DSN_CMDB"), query
CMWT_DB_IntTableGrid rs, "Errors in past 24 hours", "ComponentName", "1073741824"
CMWT_DB_CLOSE()

query = "SELECT com.SiteCode, " & _
	"com.MachineName, " & _
	"stat.MessageID, " & _
	"com.ComponentName, " & _
	"COUNT(*) as 'Warning Count' " & _
	"FROM v_StatusMessage stat " & _
	"JOIN v_ServerComponents com ON stat.SiteCode=com.SiteCode AND stat.MachineName=com.MachineName AND stat.Component=com.ComponentName " & _
	"WHERE Time > DATEADD(ss,-240-(24*3600),GETDATE()) AND Severity='-2147483648' " & _
	"GROUP BY com.SiteCode,com.MachineName,com.ComponentName,stat.MessageID " & _
	"ORDER BY COUNT(*) desc"
CMWT_DB_QUERY Application("DSN_CMDB"), query
CMWT_DB_IntTableGrid rs, "Warnings in past 24 hours", "ComponentName", "2147483648"
CMWT_DB_CLOSE()

'CMWT_SHOW_Query()
CMWT_Footer()
Response.Write "</body></html>"
%>