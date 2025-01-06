// Copyright (C) 2024 stencil-golang contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: GPL-3.0

package plugin

import (
	"fmt"

	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
)

// GetLicense returns a license from Github's License API.
func (i *Instance) GetLicense(t *apiv1.TemplateFunctionExec) (any, error) {
	licenseName, ok := t.Arguments[0].(string)
	if !ok {
		return nil, fmt.Errorf("expected string argument, got %T", t.Arguments[0])
	}

	license, _, err := i.gh.Licenses.Get(i.ctx, licenseName)
	if err != nil {
		return nil, err
	}

	return license, nil
}

// GetLicenses returns a list of commonly used licenses from Github's
// License API.
func (i *Instance) GetLicenses(_ *apiv1.TemplateFunctionExec) (any, error) {
	licenses, _, err := i.gh.Licenses.List(i.ctx)
	if err != nil {
		return nil, err
	}
	return licenses, nil
}
