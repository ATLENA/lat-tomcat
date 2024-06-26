/*
* Copyright 2022 LA:T Development Team.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package io.lat.core.valves;

import java.io.CharArrayWriter;

import org.apache.catalina.valves.AccessLogValve;

/**
 * log writes to standard output instead of file
 *
 * @sangsik
 */
public final class StdoutAccessLogValve extends AccessLogValve {

	public void log(String message) {
		System.out.println(message);
	}

	public void log(CharArrayWriter message) {
		System.out.println(message);
	}
}