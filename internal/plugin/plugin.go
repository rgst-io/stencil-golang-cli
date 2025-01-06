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

// Package plugin implements the stencil-golang plugin.
package plugin

import (
	"context"
	"fmt"

	"github.com/google/go-github/v68/github"
	"github.com/jaredallard/vcs"
	"github.com/jaredallard/vcs/token"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
)

// _ ensures that StencilGolangPlugin fits the apiv1.Implementation interface.
var _ apiv1.Implementation = &Instance{}

// Instance contains a [apiv1.Implementation] satisfying plugin.
type Instance struct {
	ctx context.Context
	gh  *github.Client
}

// New creates a new [Instance].
func New(ctx context.Context) *Instance {
	// Create an authenticated token, if possible. This gives us a higher
	// rate limit.
	tstr := ""
	t, err := token.Fetch(ctx, vcs.ProviderGithub, false, &token.Options{AllowUnauthenticated: true})
	if err == nil {
		tstr = t.Value
	}

	return &Instance{ctx: ctx, gh: github.NewClient(nil).WithAuthToken(tstr)}
}

// GetConfig returns a [apiv1.Config] for the [Instance].
func (*Instance) GetConfig() (*apiv1.Config, error) {
	return &apiv1.Config{}, nil
}

func (*Instance) GetTemplateFunctions() ([]*apiv1.TemplateFunction, error) {
	return []*apiv1.TemplateFunction{
		// GetLicense returns a license from Github's License API.
		{
			Name:              "GetLicense",
			NumberOfArguments: 1,
		},
		// GetLicenses returns a list of commonly used licenses from
		// Github's License API. This function does not take any arguments.
		{
			Name:              "GetLicenses",
			NumberOfArguments: 0,
		},
	}, nil
}

func (i *Instance) ExecuteTemplateFunction(exec *apiv1.TemplateFunctionExec) (any, error) {
	switch exec.Name {
	case "GetLicense":
		return i.GetLicense(exec)
	case "GetLicenses":
		return i.GetLicenses(exec)
	}

	return nil, fmt.Errorf("unknown template function: %s", exec.Name)
}
