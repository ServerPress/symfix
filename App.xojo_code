#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // Print hint
		  If UBound(args) < 1 Then
		    Print "symfix: missing directory"
		    Print "Usage: symfix [OPTION]... [DIRECTORY]..."
		    Print ""
		    Print "Try 'symfix --help' for more options."
		    Quit
		  End If
		  
		  // Print help 
		  If args(1).InStr("--help") > 0 Then
		    Print "symfix " + CStr(App.Version) + " cygwin symbolic link fixer for Microsoft Windows."
		    Print "Usage: symfix [OPTION]... [DIRECTORY]..."
		    Print ""
		    Print "Example: "
		    Print "  symfix -f .\"
		    Print ""
		    Print "Scans the current directory and all child folders for symbolic links"
		    Print "and restore the system attribute bit for proper functionality. It is "
		    Print "common for the attribute to be lost after zipping/un-zipping this"
		    Print "utility can restore functionality. The output will be a list of"
		    Print "found symbolic links with their complete path."
		    Print ""
		    Print "Startup:"
		    Print "  -h, --help                 print this help"
		    Print "  -f, --fix (default)        finds symbolic link files & sets system attribute"
		    Print "  -u, --unset                finds symbolic links & unsets system attribute"
		    Print "  -q, --quiet                quiet (no output)"
		    Print ""
		    Quit
		  End If
		  
		  Dim bQuiet As Boolean = False
		  Dim bFix As Boolean = True
		  Dim sPath As String = ".\"
		  For i As Integer = 0 to UBound(args)
		    args(i) = args(i).ReplaceAll("--quiet", "-q")_
		    .ReplaceAll("--fix", "-f")_
		    .ReplaceAll("--unset", "-u")
		    
		    Select Case args(i)
		    Case "-q"
		      bQuiet = True
		    Case "-u"
		      bFix = False
		    Else
		      If Left(args(i), 1) <> "-" And i <> 0 Then
		        sPath = args(i)
		      End If
		    End Select
		  Next i
		  
		  // Check path existence
		  Try
		    Dim fi As New FolderItem(sPath, FolderItem.PathTypeNative)
		    If Not fi.Exists Then
		      Print "symfix: invalid path, does not exist"
		      Quit
		    End If
		    
		    // Gather list of files via OS
		    Dim cmd As String
		    Dim LF As String = Chr(13) + Chr(10)
		    cmd = "cd " + Chr(34) + sPath + Chr(34) + LF
		    cmd = cmd + "dir /B /S" + LF
		    Dim result As String = ShellCommand(cmd).DelLeftMost("dir /B /S").Trim + LF
		    cmd = ""
		    
		    While result.InStrB(LF) > 0
		      Dim file As String = result.GetLeftMost(LF)
		      result = result.DelLeftMost(LF)
		      
		      // Check if file is symbolic link
		      fi = New FolderItem(file, FolderItem.PathTypeNative)
		      If Not fi.Directory And fi.Length < 300 Then // Optimize, files are less than 300 bytes
		        Dim tis As TextInputStream
		        tis = TextInputStream.Open(fi)
		        Dim line As String = tis.Read(10)
		        tis.Close
		        If line = "!<symlink>" Then
		          If Not bQuiet Then
		            Print file
		          End If
		          If bFix Then
		            cmd = cmd + "attrib +s " + Chr(34) + file + Chr(34) + LF
		          Else
		            cmd = cmd + "attrib -s " + Chr(34) + file + Chr(34) + LF
		          End If
		        End If
		      End If
		    Wend
		    Call ShellCommand(cmd)
		  Catch e As RuntimeException
		    Print e.Message
		  End Try
		  
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Function GetFiles(sPath As String) As String()
		  Dim fi As New FolderItem(sPath, FolderItem.PathTypeNative)
		  Dim sFiles() As String
		  For i As Integer = 1 to fi.Count
		    If Not fi.Item(i).Directory Then
		      sFiles.Append(fi.Item(i).NativePath)
		    Else
		      Dim sExtras() As String = GetFiles(fi.Item(i).NativePath)
		      For a As Integer = 0 to UBound(sExtras)
		        sFiles.Append(sExtras(a))
		      Next a
		      App.DoEvents 1
		    End If
		  Next i
		  Return sFiles
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ShellCommand(sCmd As String) As String
		  // Write the given command to a temp batch file to execute and return the results
		  Dim fi As FolderItem = SpecialFolder.Temporary.Child(App.ExecutableFile.Name + ".bat")
		  Dim tos As TextOutputStream
		  If fi.Exists Then fi.Delete
		  tos = TextOutputStream.Create(fi)
		  tos.Write(sCmd)
		  tos.Close
		  Dim sh As New Shell
		  sh.Mode = 0
		  sh.Execute fi.NativePath
		  Dim r As String = sh.Result
		  sh.Close
		  fi.Delete
		  Return r
		  
		End Function
	#tag EndMethod


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
