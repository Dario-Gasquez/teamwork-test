//
//  Logging.swift
//  Trophy Hunter
//
//  Created by Dario on 1/25/18.
//  Copyright © 2018 Dario. All rights reserved.
//

import Foundation

enum LogLevel : String, CustomStringConvertible {
    case Info
    case Warning
    case Error
    
    var description : String {
        return self.rawValue
    }
    
    var shouldLog : Bool {
        #if DEBUG
            return true
        #else
            return self == .Error || self == .Warning
        #endif
    }
    
    var shouldBreak : Bool {
        #if DEBUG
            if self != .Error {
                return false
            }
            
            /*
             "How do I determine if I'm being run under the debugger?"
             https://developer.apple.com/library/ios/qa/qa1361/_index.html
             */
            var info = kinfo_proc()
            var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
            var size = MemoryLayout.stride(ofValue: info)
            sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
            return (info.kp_proc.p_flag & P_TRACED) != 0
        #else
            return false
        #endif
    }
}

/// Logs a message to the console (if the `level` parameter allows it) and will break into the debugger if `level` is `.Error` and a debugger is attached (only in Release builds)
func logMessage(_ level: LogLevel, _ items: String, file: StaticString = #file, line: UInt = #line, function: String = #function) {
    if level.shouldLog {
        // NSLog goes to the device console when a debugger is not attached, but `print` does not.
        NSLog("\n\(level): <\(sourceFileName(filePath: file)).\(function):\(line)> : \(items)")
        if level.shouldBreak {
            
            // raise(SIGSTOP) will break into the debugger, and you can continue executing. But it will break the main thread, so let's make sure we're there before breaking.
            if Thread.isMainThread {
                raise(SIGSTOP)
            }
            else {
                _ = DispatchQueue.main.sync {
                    raise(SIGSTOP)
                }
            }
        }
    }
}

fileprivate func sourceFileName(filePath: StaticString) -> String {
    let components = String(describing: filePath).components(separatedBy: "/")
    return components.isEmpty ? "" : components.last!
}

